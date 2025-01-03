//
// The MIT License (MIT)
//
// Copyright © 2025 Ilya Baryka. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

final class SocketFactoryImpl: SocketFactory {
    typealias SocketCommand = CommandBlock<Data>
    
    func create(command: SocketCommand) throws -> any PingxSocket {
        let unmanaged = Unmanaged.passRetained(command)
        var context = CFSocketContext(
            version: .zero,
            info: unmanaged.toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil
        )
        let socket = CFSocketCreate(
            kCFAllocatorDefault,
            AF_INET,
            SOCK_DGRAM,
            IPPROTO_ICMP,
            CFSocketCallBackType.dataCallBack.rawValue, { _, callbackType, _, data, info in
                guard
                    let data = data,
                    let info = info,
                    (callbackType as CFSocketCallBackType) == CFSocketCallBackType.dataCallBack
                else { return }
                
                let commandBlock = Unmanaged<SocketCommand>.fromOpaque(info).takeUnretainedValue()
                let cfdata = Unmanaged<CFData>.fromOpaque(data).takeUnretainedValue()
                commandBlock.closure(cfdata as Data)
            },
            &context
        )
        
        guard let socket = socket else { throw PacketSenderError.socketCreationError }
        let native = CFSocketGetNative(socket)
        var value: Int32 = 1
        
        guard setsockopt(
            native,
            SOL_SOCKET,
            SO_NOSIGPIPE,
            &value,
            socklen_t(MemoryLayout.size(ofValue: value))
        ) == .zero else {
            throw PacketSenderError.socketCreationError
        }
        
        guard let socketSource = CFSocketCreateRunLoopSource(
            kCFAllocatorDefault,
            socket,
            .zero
        ) else { throw PacketSenderError.socketCreationError }
        
        CFRunLoopAddSource(
            CFRunLoopGetMain(),
            socketSource,
            .commonModes
        )
        
        return PingxSocketImpl(
            socket: socket,
            socketSource: socketSource,
            unmanaged: unmanaged
        )
    }
}
