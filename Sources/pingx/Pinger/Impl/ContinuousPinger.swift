import Foundation

// MARK: - ContinuousPinger

public final class ContinuousPinger {
    
    // MARK: Delegate
    
    public weak var delegate: PingerDelegate?
    
    // MARK: Properties
    
    private let configuration: PingerConfiguration
    private let packetSender: PacketSender
    private let timerFactory: TimerFactory
    
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
    
    init(
        configuration: PingerConfiguration,
        packetSender: PacketSender = PacketSenderImpl(),
        timerFactory: TimerFactory = TimerFactoryImpl()
    ) {
        self.configuration = configuration
        self.packetSender = packetSender
        self.timerFactory = timerFactory
        packetSender.delegate = self
    }
    
    public convenience init(
        configuration: PingerConfiguration = PingerConfiguration()
    ) {
        self.init(
            configuration: configuration,
            packetSender: PacketSenderImpl(),
            timerFactory: TimerFactoryImpl()
        )
    }
    
    deinit {
        invalidate()
    }
}

// MARK: - Private API

private extension ContinuousPinger {
    func setUpTimer() {
        let timer = timerFactory.create(timeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateOutgoingRequests()
        }
        
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }
    
    func updateOutgoingRequests() {
        for (key, request) in outgoingRequests {
            let newTimeRemainingUntilDeadline = request.timeRemainingUntilDeadline - 1
            outgoingRequests[key]?.setTimeRemainingUntilDeadline(newTimeRemainingUntilDeadline)
            
            guard newTimeRemainingUntilDeadline <= .zero else { continue }
            
            delegate?.pinger(self, request: request, didCompleteWithError: .timeout)
            outgoingRequests[key]?.setDemand(request.demand - .max(1))
            outgoingRequests[key]?.setTimeRemainingUntilDeadline(request.timeoutInterval)
            
            guard let request = outgoingRequests[key] else { return }
            
            outgoingRequests.removeValue(forKey: key)
            ping(request: request)
        }
    }
    
    func invalidate() {
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
        guard request.demand != .none else { return }
        
        do {
            outgoingRequests[request.destination] = request
            try packetSender.send(request)
        } catch _ as PacketSenderError {
            outgoingRequests.removeValue(forKey: request.destination)
            delegate?.pinger(self, request: request, didCompleteWithError: .socketFailed)
        } catch {}
    }
    
    public func stop(ipv4Address: IPv4Address) {
        outgoingRequests.removeValue(forKey: ipv4Address)
    }
}

// MARK: - PacketSenderDelegate

extension ContinuousPinger: PacketSenderDelegate {
    func packetSender(packetSender: PacketSender, didReceive data: Data) {
        do {
            let package = try extractICMPPackage(from: data)
            let response = Response(
                destination: package.ipHeader.sourceAddress,
                duration: (CFAbsoluteTimeGetCurrent() - package.icmpHeader.payload.timestamp) * 1000
            )
            
            guard var request = outgoingRequests[response.destination] else { return }
            
            request.setDemand(request.demand - .max(1))
            request.setTimeRemainingUntilDeadline(request.timeoutInterval)
            delegate?.pinger(self, request: request, didReceive: response)
            
            guard request.demand != .none else {
                outgoingRequests.removeValue(forKey: response.destination)
                return
            }
            
            DispatchQueue.global().asyncAfter(deadline: .now() + configuration.interval) { [weak self] in
                self?.outgoingRequests.removeValue(forKey: response.destination)
                self?.ping(request: request)
            }
        } catch let error as ICMPResponseValidationError {
            handleValidationError(error)
        } catch {}
    }
    
    private func handleValidationError(_ error: ICMPResponseValidationError) {
        switch error {
        case .checksumMismatch(let ipHeader),
             .invalidCode(let ipHeader),
             .invalidType(let ipHeader),
             .missedIcmpHeader(let ipHeader),
             .invalidIdentifier(let ipHeader):
            
            guard let request = outgoingRequests[ipHeader.sourceAddress] else { return }
            
            outgoingRequests.removeValue(forKey: ipHeader.sourceAddress)
            delegate?.pinger(self, request: request, didCompleteWithError: .invalidResponseStructure)
            
        case .missedIpHeader:
            return
        }
    }
}
