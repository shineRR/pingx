// MARK: - SinglePinger

public final class SinglePinger {
    
    // MARK: Delegate
    
    public weak var delegate: PingerDelegate?
    
    // MARK: Properties
    
    private let packetSender: PacketSenderProtocol

    // MARK: Initializer
    
    public init() {
        let packetSender = PacketSender()
        self.packetSender = packetSender
        packetSender.delegate = self
    }
}

// MARK: - Pinger

extension SinglePinger: Pinger {
    public func ping(request: Request) {
        do {
            try packetSender.send(request)
        } catch let error as PingerError {
            delegate?.pinger(self, request: request, didCompleteWithError: error)
        } catch {}
    }
}

// MARK: - PacketSenderDelegate

extension SinglePinger: PacketSenderDelegate {
    func packetSender(packetSender: PacketSender, didReceive data: Data) {
        print(extractResponse(from: data))
    }
}
