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
