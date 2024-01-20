// MARK: - PacketSender

final class PacketSender {

    // MARK: Delegate
    
    weak var delegate: PacketSenderDelegate?
    
    // MARK: Properties
    
    private var socket: CFSocket!
    private let socketFactory: SocketFactory
    private let packetFactory: PacketFactory
    
    // MARK: Initializer
    
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
        guard socket == nil else { return }
        
        let command: CommandBlock<Data> = CommandBlock { [weak self] data in
            guard let self else { return }
            self.delegate?.packetSender(packetSender: self, didReceive: data)
        }
        
        socket = try socketFactory.create(command: command)
    }
}

// MARK: - IPacketSender

extension PacketSender: PacketSenderProtocol {
    func send(_ request: Request) throws {
        try checkSocketCreation()
        
        let packet = try packetFactory.create(type: request.type)
        let error = CFSocketSendData(
            socket,
            request.destination.socketAddress as CFData,
            packet.data as CFData,
            request.timeoutInterval
        )
        
        try handleSocketError(error)
    }
    
    private func handleSocketError(_ error: CFSocketError) throws {
        switch error {
        case .success:
            break
        case .error:
            throw PingerError.socketFailed
        case .timeout:
            throw PingerError.timeout
        }
    }
}
