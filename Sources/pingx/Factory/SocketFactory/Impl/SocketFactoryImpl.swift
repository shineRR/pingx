import Foundation

// MARK: - SocketFactoryImpl

final class SocketFactoryImpl {
    
    // MARK: Typealias
    
    typealias SocketCommand = CommandBlock<Data>
}

// MARK: - SocketFactory

extension SocketFactoryImpl: SocketFactory {
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
            CFSocketCallBackType.dataCallBack.rawValue, { _, callbackType, address, data, info in
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
        guard let socketSource = CFSocketCreateRunLoopSource(
            kCFAllocatorDefault,
            socket,
            .zero
        ) else { throw PingerError.socketFailed }
        
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
