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

final class PacketSenderImpl {

    // MARK: Typealias
    
    private typealias Instance = SocketFactoryImpl.SocketCommand
    
    // MARK: Delegate
    
    weak var delegate: PacketSenderDelegate?
    
    // MARK: Properties
    
    private let socketFactory: SocketFactory
    private let packetFactory: PacketFactory
    private var pingxSocket: (any PingxSocket)!
    
    // MARK: Initializer

    init(
        socketFactory: SocketFactory = SocketFactoryImpl(),
        packetFactory: PacketFactory = PacketFactoryImpl()
    ) {
        self.socketFactory = socketFactory
        self.packetFactory = packetFactory
    }
    
    deinit {
        invalidate()
    }
}

// MARK: - PacketSender

extension PacketSenderImpl: PacketSender {
    func send(_ request: Request) {
        do {
            try checkSocketCreation()
        } catch {
            delegate?.packetSender(packetSender: self, request: request, didCompleteWithError: .socketCreationError)
            return
        }
        
        guard let packet = try? packetFactory.create(identifier: request.id, type: request.type) else {
            delegate?.packetSender(packetSender: self, request: request, didCompleteWithError: .unableToCreatePacket)
            return
        }
        
        let error = pingxSocket.send(
            address: request.destination.socketAddress as CFData,
            data: packet.data as CFData,
            timeout: request.sendTimeout
        )
        handleSocketError(error, request: request)
    }
    
    func invalidate() {
        guard pingxSocket != nil else { return }
        pingxSocket.invalidate()
        pingxSocket = nil
    }
}

// MARK: - Private API

private extension PacketSenderImpl {
    func checkSocketCreation() throws {
        guard pingxSocket == nil else { return }
        
        let command: CommandBlock<Data> = CommandBlock { [weak self] data in
            guard let self else { return }
            self.delegate?.packetSender(packetSender: self, didReceive: data)
        }
        
        pingxSocket = try socketFactory.create(command: command)
    }
    
    func handleSocketError(_ error: CFSocketError, request: Request) {
        switch error {
        case .error:
            delegate?.packetSender(packetSender: self, request: request, didCompleteWithError: .error)
        case .timeout:
            delegate?.packetSender(packetSender: self, request: request, didCompleteWithError: .timeout)
        default:
            return
        }
    }
}
