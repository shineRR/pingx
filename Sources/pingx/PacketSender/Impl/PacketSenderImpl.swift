import Foundation

// MARK: - PacketSenderImpl

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
}

// MARK: - PacketSender

extension PacketSenderImpl: PacketSender {
    func send(_ request: Request) throws {
        try checkSocketCreation()
        
        let packet = packetFactory.create(type: request.type)
        let error = pingxSocket.send(
            address: request.destination.socketAddress as CFData,
            data:  packet.data as CFData,
            timeout: request.timeoutInterval
        )
        
        try handleSocketError(error)
    }
    
    func invalidate() {
        guard pingxSocket != nil else { return }
        pingxSocket.invalidate()
        pingxSocket = nil
    }
    
    private func handleSocketError(_ error: CFSocketError) throws {
        switch error {
        case .error:
            throw PacketSenderError.error
        case .timeout:
            throw PacketSenderError.timeout
        default:
            return
        }
    }
}
