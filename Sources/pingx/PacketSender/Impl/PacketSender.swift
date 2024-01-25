import Foundation

// MARK: - PacketSender

final class PacketSender {

    // MARK: Typealias
    
    private typealias Instance = SocketFactoryImpl.SocketCommand
    
    // MARK: Delegate
    
    weak var delegate: PacketSenderDelegate?
    
    // MARK: Properties
    
    private let socketFactory: SocketFactory
    private let packetFactory: PacketFactory
    private var pingxSocket: PingxSocket<Instance>!
    
    // MARK: Initializer
    
    // TODO: Add queue/thread
    init(
        socketFactory: SocketFactory = SocketFactoryImpl(),
        packetFactory: PacketFactory = PacketFactoryImpl()
    ) {
        self.socketFactory = socketFactory
        self.packetFactory = packetFactory
    }
}

// MARK: - Private API

private extension PacketSender {
    func checkSocketCreation() throws {
        guard pingxSocket == nil else { return }
        
        let command: CommandBlock<Data> = CommandBlock { [weak self] data in
            guard let self else { return }
            self.delegate?.packetSender(packetSender: self, didReceive: data)
        }
        
        pingxSocket = try socketFactory.create(command: command)
    }
}

// MARK: - IPacketSender

extension PacketSender: PacketSenderProtocol {
    func send(_ request: Request) throws {
        try checkSocketCreation()
        
        let packet = packetFactory.create(type: request.type)
        let error = CFSocketSendData(
            pingxSocket.socket,
            request.destination.socketAddress as CFData,
            packet.data as CFData,
            request.timeoutInterval
        )
        
        try handleSocketError(error)
    }
    
    func invalidate() {
        guard pingxSocket != nil else { return }
        CFRunLoopSourceInvalidate(pingxSocket.socketSource)
        CFSocketInvalidate(pingxSocket.socket)
        pingxSocket.unmanaged.release()
        pingxSocket = nil
    }
    
    private func handleSocketError(_ error: CFSocketError) throws {
        switch error {
        case .error:
            throw PingerError.socketFailed
        case .timeout:
            throw PingerError.timeout
        default:
            return
        }
    }
}
