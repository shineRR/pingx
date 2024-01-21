// MARK: - SinglePinger

public final class SinglePinger {
    
    // MARK: Delegate
    
    public weak var delegate: PingerDelegate?
    
    // MARK: Properties
    
    private let packetSender: PacketSenderProtocol
    
    @Atomic
    private var outgoingRequests: [IPv4Address: Request] = [:] {
        didSet {
            guard !outgoingRequests.isEmpty else {
                invalidateTimer()
                return
            }
            guard timer == nil else { return }
            
            setUpTimer()
        }
    }
    private var timer: Timer?
    
    // MARK: Initializer
    
    public init() {
        let packetSender = PacketSender()
        self.packetSender = packetSender
        packetSender.delegate = self
    }
}

// MARK: - Private API

private extension SinglePinger {
    func setUpTimer() {
        timer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { [weak self] timer in
            self?.updateOutgoingRequests()
        }
    }
    
    func updateOutgoingRequests() {
        for (key, request) in outgoingRequests {
            let newValue = request.timeRemainingUntilDeadline - 1
            outgoingRequests[key]?.setTimeRemainingUntilDeadline(newValue)
            
            guard newValue <= .zero else { continue }
            
            outgoingRequests.removeValue(forKey: key)
            delegate?.pinger(self, request: request, didCompleteWithError: .timeout)
        }
    }
    
    func invalidateTimer() {
        packetSender.invalidate()
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Pinger

extension SinglePinger: Pinger {
    public func ping(request: Request) {
        guard outgoingRequests[request.destination] == nil else {
            delegate?.pinger(self, request: request, didCompleteWithError: .isOutgoing)
            return
        }
        
        do {
            outgoingRequests[request.destination] = request
            try packetSender.send(request)
        } catch let error as PingerError {
            outgoingRequests.removeValue(forKey: request.destination)
            delegate?.pinger(self, request: request, didCompleteWithError: error)
        } catch {}
    }
}

// MARK: - PacketSenderDelegate

extension SinglePinger: PacketSenderDelegate {
    func packetSender(packetSender: PacketSenderProtocol, didReceive data: Data) {
        do {
            let package = try extractICMPPackage(from: data)
            let response = Response(
                destination: package.ipHeader.sourceAddress,
                duration: (CFAbsoluteTimeGetCurrent() - package.icmpHeader.payload.timestamp) * 1000
            )
            let request = outgoingRequests[
                response.destination,
                default: .init(destination: response.destination)
            ]
            
            outgoingRequests.removeValue(forKey: response.destination)
            delegate?.pinger(self, request: request, didReceive: response)
        } catch let error as ICMPResponseValidationError {
            switch error {
            case .checksumMismatch(let ipHeader), .invalidCode(let ipHeader),
                 .invalidType(let ipHeader), .missedIcmpHeader(let ipHeader):
                
                let request = outgoingRequests[ipHeader.sourceAddress]
                outgoingRequests.removeValue(forKey: ipHeader.sourceAddress)
                
                guard let request else { return }
                delegate?.pinger(self, request: request, didCompleteWithError: .invalidResponseStructure)
                
            case .missedIpHeader:
                return
            }
        } catch {}
    }
}
