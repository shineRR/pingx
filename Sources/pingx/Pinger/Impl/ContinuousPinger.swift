import Foundation

// MARK: - ContinuousPinger

public final class ContinuousPinger: Pinger {
    
    // MARK: Delegate
    
    public weak var delegate: PingerDelegate?
    
    // MARK: Properties
    
    private let pingerQueue = DispatchQueue(
        label: "com.pingx.ContinuousPinger.pingerQueue",
        qos: .userInitiated
    )
    private let configuration: PingerConfiguration
    private let packetSender: PacketSender
    private let timerFactory: TimerFactory

    @Atomic
    private var outgoingRequests: [UInt16: Request] = [:] {
        didSet {
            if outgoingRequests.isEmpty {
                invalidateTimer()
            } else if timer == nil {
                setUpTimer()
            }
        }
    }

    @Atomic
    private var timer: PingxTimer?
    
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
        invalidateTimer()
    }
    
    public func ping(request: Request) {
        func validateAndSendRequest() {
            guard outgoingRequests[request.id] == nil else {
                delegate?.pinger(self, request: request, didCompleteWithError: .pingInProgress)
                return
            }

            guard request.demand != .none else {
                delegate?.pinger(self, request: request, didCompleteWithError: .invalidDemand)
                return
            }

            outgoingRequests[request.id] = request
            packetSender.send(request)
        }
        
        perform(validateAndSendRequest, on: pingerQueue)
    }
    
    public func stop(request: Request) {
        outgoingRequests.removeValue(forKey: request.id)
    }
    
    public func stop(requestId: Request.ID) {
        outgoingRequests.removeValue(forKey: requestId)
    }
}

// MARK: - Private API

private extension ContinuousPinger {
    func setUpTimer() {
        timer = timerFactory.createDispatchSourceTimer(timeInterval: 1.0, eventQueue: pingerQueue) { [weak self] in
            self?.updateTimeoutTimeForOutgoingRequests()
        }
    }
    
    func updateTimeoutTimeForOutgoingRequests() {
        for request in outgoingRequests.values {
            let newTimeRemainingUntilDeadline = request.timeRemainingUntilDeadline - 1

            if newTimeRemainingUntilDeadline <= .zero {
                request.decreaseDemandAndUpdateTimeRemainingUntilDeadline()
                delegate?.pinger(self, request: request, didCompleteWithError: .timeout)
            } else {
                request.setTimeRemainingUntilDeadline(newTimeRemainingUntilDeadline)
            }
        
            scheduleNextRequestIfPositiveDemand(request)
        }
    }
    
    func invalidateTimer() {
        timer?.stop()
        timer = nil
    }

    func scheduleNextRequestIfPositiveDemand(_ request: Request) {
        guard request.demand != .none else {
            outgoingRequests.removeValue(forKey: request.id)
            return
        }
        
        performAfter(
            deadline: .now() + configuration.interval,
            packetSender.send,
            value: request,
            on: pingerQueue
        )
    }
}

// MARK: - PacketSenderDelegate

extension ContinuousPinger: PacketSenderDelegate {
    func packetSender(packetSender: PacketSender, didReceive data: Data) {
        perform(handlePacketSenderResponse, value: data, on: pingerQueue)
    }
    
    private func handlePacketSenderResponse(data: Data) {
        do {
            let package = try extractICMPPackage(from: data)
            let response = Response(
                destination: package.ipHeader.sourceAddress,
                duration: (CFAbsoluteTimeGetCurrent() - package.icmpHeader.payload.timestamp) * 1000
            )

            guard let request = outgoingRequests[package.icmpHeader.identifier] else { return }
            request.decreaseDemandAndUpdateTimeRemainingUntilDeadline()
            delegate?.pinger(self, request: request, didReceive: response)
            
            scheduleNextRequestIfPositiveDemand(request)
        } catch let error as ICMPResponseValidationError {
            guard let icmpHeader = error.icmpHeader, let request = outgoingRequests[icmpHeader.identifier] else { return }
            request.decreaseDemandAndUpdateTimeRemainingUntilDeadline()
            
            delegate?.pinger(self, request: request, didCompleteWithError: .invalidResponse)
            scheduleNextRequestIfPositiveDemand(request)
        } catch {}
    }
    
    func packetSender(packetSender: PacketSender, request: Request, didCompleteWithError error: PacketSenderError) {
        perform(handlePacketSenderSockerFailure, value: request, on: pingerQueue)
    }
    
    private func handlePacketSenderSockerFailure(request: Request) {
        request.decreaseDemandAndUpdateTimeRemainingUntilDeadline()

        delegate?.pinger(self, request: request, didCompleteWithError: .socketFailed)
        scheduleNextRequestIfPositiveDemand(request)
    }
}

private func performAfter<T>(
    deadline: DispatchTime,
    _ function: @escaping (T) -> Void,
    value: T,
    on queue: DispatchQueue
) {
    queue.asyncAfter(deadline: deadline) {
        function(value)
    }
}

private func perform<T>(_ function: @escaping (T) -> Void, value: T, on queue: DispatchQueue) {
    queue.async {
        function(value)
    }
}

private func perform(_ function: @escaping () -> Void, on queue: DispatchQueue) {
    queue.async(execute: function)
}
