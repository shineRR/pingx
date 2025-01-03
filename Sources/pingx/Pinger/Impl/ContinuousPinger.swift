//
// The MIT License (MIT)
//
// Copyright © 2025 Ilya Baryka. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

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
        pingerQueue.async { [weak self] in
            self?.outgoingRequests.removeValue(forKey: request.id)
        }
    }
    
    public func stop(requestId: Request.ID) {
        pingerQueue.async { [weak self] in
            self?.outgoingRequests.removeValue(forKey: requestId)
        }
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
            guard
                let icmpHeader = error.icmpHeader,
                let request = outgoingRequests[icmpHeader.identifier]
            else { return }
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
