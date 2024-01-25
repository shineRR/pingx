import Foundation

// MARK: - ContinuousPinger

public final class ContinuousPinger {
    
    // MARK: Delegate
    
    public weak var delegate: PingerDelegate?
    
    // MARK: Properties
    
    private let packetSender: PacketSenderProtocol
    
    @Atomic
    private var outgoingRequests: [IPv4Address: Request] = [:] {
        didSet {
            guard !outgoingRequests.isEmpty else {
                invalidate()
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

private extension ContinuousPinger {
    func setUpTimer() {
        timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] timer in
            self?.updateOutgoingRequests()
        }
        
        guard let timer else { return }
        RunLoop.main.add(timer, forMode: .common)
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
    
    func invalidate() {
        packetSender.invalidate()
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Pinger

extension ContinuousPinger: Pinger {
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
    
    public func stop(ipv4Address: IPv4Address) {
        outgoingRequests.removeValue(forKey: ipv4Address)
    }
}

// MARK: - PacketSenderDelegate

extension ContinuousPinger: PacketSenderDelegate {
    func packetSender(packetSender: PacketSenderProtocol, didReceive data: Data) {
        do {
            let package = try extractICMPPackage(from: data)
            let response = Response(
                destination: package.ipHeader.sourceAddress,
                duration: (CFAbsoluteTimeGetCurrent() - package.icmpHeader.payload.timestamp) * 1000
            )
            guard var request = outgoingRequests[response.destination] else { return }
            
            outgoingRequests.removeValue(forKey: response.destination)
            delegate?.pinger(self, request: request, didReceive: response)
            request.setTimeRemainingUntilDeadline(request.timeoutInterval)
            ping(request: request)
        } catch let error as ICMPResponseValidationError {
            switch error {
            case .checksumMismatch(let ipHeader), .invalidCode(let ipHeader),
                 .invalidType(let ipHeader), .missedIcmpHeader(let ipHeader),
                 .invalidIdentifier(let ipHeader):
                
                guard let request = outgoingRequests[ipHeader.sourceAddress] else { return }
                
                outgoingRequests.removeValue(forKey: ipHeader.sourceAddress)
                delegate?.pinger(self, request: request, didCompleteWithError: .invalidResponseStructure)
                
            case .missedIpHeader:
                return
            }
        } catch {}
    }
}
