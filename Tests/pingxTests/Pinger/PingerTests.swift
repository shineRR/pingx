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

import XCTest
@testable import pingx

final class PingerTests: XCTestCase {
    
    // MARK: Constants

    private enum Constants {
        static var ipv4: IPv4Address { .init(address: (8, 8, 8, 8)) }
    }
    
    // MARK: Properties
    
    private var timer: PingxTimerMock!
    private var timerFactory: TimerFactoryMock!
    private var packetSender: PacketSenderMock!
    private var pingerDelegate: PingerDelegateMock!
    private var pinger: ContinuousPinger!
    
    // MARK: Override
    
    override func setUp() {
        super.setUp()
        
        packetSender = PacketSenderMock()
        pingerDelegate = PingerDelegateMock()
        
        timer = PingxTimerMock()
        timerFactory = TimerFactoryMock()
        timerFactory.createDispatchSourceTimerReturnValue = timer

        pinger = ContinuousPinger(
            configuration: PingerConfiguration(interval: .seconds(.zero)),
            packetSender: packetSender,
            timerFactory: timerFactory
        )
        pinger.delegate = pingerDelegate
    }
    
    override func tearDown() {
        super.tearDown()

        timer = nil
        timerFactory = nil
        pingerDelegate = nil
        packetSender = nil
        pinger = nil
    }
    
    // MARK: Tests
    
    func test_start_whenRequestIsNotOutgoingAndDemandIsGreaterThanZero_sendsPingRequest() {
        let request = Request(destination: Constants.ipv4, demand: .max(1))

        pinger.ping(request: request)
        
        XCTAssertEventuallyEqual(self.packetSender.sendReceivedInvocations, [request])
        XCTAssertEventuallyEqual(self.timerFactory.createDispatchSourceTimerCallsCount, 1)
    }
    
    func test_start_whenRequestIsOutgoingAndDemandIsGreaterThanZero_returnsIsOutgoingError() {
        let request = Request(destination: Constants.ipv4, demand: .max(1))

        pinger.ping(request: request)
        pinger.ping(request: request)
        
        XCTAssertEventuallyEqual(self.packetSender.sendReceivedInvocations, [request])
        XCTAssertEqual(timerFactory.createDispatchSourceTimerCallsCount, 1)
        XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorCalledCount, 1)
        XCTAssertTrue(pingerDelegate.pingerDidCompleteWithErrorInvocations[0].pinger === pinger)
        XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorInvocations[0].error, .pingInProgress)
        XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorInvocations[0].request, request)
    }
    
    func test_start_whenDemandIsZero_doesNotSendRequest() {
        let request = Request(destination: Constants.ipv4, demand: .max(0))

        pinger.ping(request: request)
        
        XCTAssertEqual(packetSender.sendCallsCount, 0)
        XCTAssertEqual(timerFactory.createDispatchSourceTimerCallsCount, 0)
    }

    func test_stop_invalidatesTimer() {
        let request = Request(destination: Constants.ipv4)
        
        pinger.ping(request: request)
        pinger.stop(request: request)
        
        XCTAssertEventuallyEqual(self.timer.stopCallsCount, 1)
    }
    
    func test_stopByRequestId_invalidatesTimer() {
        let request = Request(destination: Constants.ipv4)
        
        pinger.ping(request: request)
        pinger.stop(requestId: request.id)
        
        XCTAssertEventuallyEqual(self.timer.stopCallsCount, 1)
    }
    
    func test_stop_whenResponseReceived_doesNotNotifyDelegate() throws {
        let request = Request(destination: Constants.ipv4)
        
        pinger.ping(request: request)
        pinger.stop(request: request)
        try simulateValidResponse(for: request)
        
        XCTAssertEqual(pingerDelegate.pingerDidReceiveResponseCalledCount, 0)
        XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorCalledCount, 0)
    }
    
    func test_deinit_invalidatesTimer() {
        let request = Request(destination: Constants.ipv4)
        pinger.ping(request: request)
        
        pinger = nil

        XCTAssertEventuallyEqual(self.timer.stopCallsCount, 1)
    }
}

// MARK: - Demand Tests

extension PingerTests {
    func test_demand_whenZero_throwsError() {
        let request = Request(destination: Constants.ipv4, demand: .none)
        
        pinger.ping(request: request)
        
        XCTAssertEventuallyEqual(self.pingerDelegate.pingerDidReceiveResponseCalledCount, 0)
        XCTAssertEventuallyEqual(self.pingerDelegate.pingerDidCompleteWithErrorCalledCount, 1)
        XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorInvocations[0].error, .invalidDemand)
    }
    
    func test_demand_whenLimited_sendsRequestMultipleTimes() throws {
        let demandValue = 2
        let request = Request(destination: Constants.ipv4, demand: .max(demandValue))

        pinger.ping(request: request)

        for index in 0...demandValue {
            try simulateValidResponse(for: request)
            
            let expectedDemandValue = demandValue - index - 1
            let expectedDemand: Request.Demand = expectedDemandValue > 0 ? .max(expectedDemandValue) : .none
            XCTAssertEventuallyEqual(request.demand, expectedDemand)
        }
        
        XCTAssertEventuallyEqual(self.pingerDelegate.pingerDidReceiveResponseCalledCount, 2)
        XCTAssertEventuallyEqual(self.packetSender.sendCallsCount, 2)
        XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorCalledCount, 0)
    }
}

// MARK: - Error Tests

extension PingerTests {
    func test_error_whenRequestIsTimedOut() {
        let timeoutInterval: TimeInterval = 5
        let request = Request(destination: Constants.ipv4, timeoutInterval: timeoutInterval)
        
        pinger.ping(request: request)
        
        XCTAssertEventuallyEqual(self.packetSender.sendCallsCount, 1)
        
        for _ in 0..<Int(timeoutInterval) {
            timerFactory.createDispatchSourceTimerReceivedInvocations.last?.eventHandler()
        }
        
        XCTAssertEqual(pingerDelegate.pingerDidReceiveResponseCalledCount, 0)
        XCTAssertEventuallyEqual(self.pingerDelegate.pingerDidCompleteWithErrorCalledCount, 1)
        XCTAssertTrue(pingerDelegate.pingerDidCompleteWithErrorInvocations[0].pinger === pinger)
        XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorInvocations[0].request, request)
        XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorInvocations[0].error, .timeout)
    }
    
    func test_error_whenIpHeaderMissed_doesNotNotifyDelegate() {
        let request = Request(destination: Constants.ipv4, demand: .unlimited)
        
        pinger.ping(request: request)
        simulateErrorResponse(for: request, error: .missedIpHeader)
        
        XCTAssertEqual(pingerDelegate.pingerDidReceiveResponseCalledCount, 0)
        XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorCalledCount, 0)
    }
    
    func test_error_whenValidationFailed_resendsRequest() {
        let demandValue = 2
        let request = Request(destination: Constants.ipv4, demand: .max(demandValue))
        let icmpHeader = ICMPHeader.sample(type: .echoReply, identifier: request.id)
        
        pinger.ping(request: request)
        
        for index in 0...demandValue {
            simulateErrorResponse(for: request, error: .invalidPayload(icmpHeader))
            
            let expectedDemandValue = demandValue - index - 1
            let expectedDemand: Request.Demand = expectedDemandValue > 0 ? .max(expectedDemandValue) : .none
            XCTAssertEventuallyEqual(request.demand, expectedDemand)
        }
        
        XCTAssertEventuallyEqual(self.packetSender.sendCallsCount, 2)
    }

    func test_error_whenValidationFailed_notifiesDelegateAboutInvalidResponse() {
        let request = Request(destination: Constants.ipv4, demand: .unlimited)
        let validationErrors: [ICMPResponseValidationError] = [
            .checksumMismatch(
                .sample(type: .echoReply, identifier: request.id)
            ),
            .invalidCode(
                .sample(type: .echoReply, code: UInt8.random(in: 200...255), identifier: request.id)
            ),
            .invalidPayload(
                .sample(
                    type: .echoReply,
                    identifier: request.id,
                    payload: Payload(identifier: (0, 0, 0, 0, 0, 0, 0, 0))
                )
            ),
            .invalidType(
                .sample(type: .routerSolicitation, identifier: request.id)
            )
        ]
        
        pinger.ping(request: request)
        
        for (index, error) in validationErrors.enumerated() {
            simulateErrorResponse(for: request, error: error)

            XCTAssertEventuallyEqual(self.pingerDelegate.pingerDidCompleteWithErrorCalledCount, index + 1)
            XCTAssertTrue(pingerDelegate.pingerDidCompleteWithErrorInvocations[index].pinger === pinger)
            XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorInvocations[index].request, request)
            XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorInvocations[index].error, .invalidResponse)
        }
    }
    
    func test_packetSenderSocketFailure_notifiesDelegate() {
        let request = Request(destination: Constants.ipv4, demand: .unlimited)
        
        pinger.ping(request: request)
        pinger.packetSender(packetSender: packetSender, request: request, didCompleteWithError: .socketCreationError)
        
        XCTAssertEventuallyEqual(self.pingerDelegate.pingerDidCompleteWithErrorCalledCount, 1)
        XCTAssertTrue(pingerDelegate.pingerDidCompleteWithErrorInvocations[0].pinger === pinger)
        XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorInvocations[0].request, request)
        XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorInvocations[0].error, .socketFailed)
    }
    
    func test_packetSenderSocketFailure_resendsRequest() {
        let request = Request(destination: Constants.ipv4, demand: .unlimited)
        
        pinger.ping(request: request)
        pinger.packetSender(packetSender: packetSender, request: request, didCompleteWithError: .socketCreationError)
        
        XCTAssertEventuallyEqual(self.packetSender.sendCallsCount, 2)
    }
}

private extension PingerTests {
    func simulateValidResponse(for request: Request) throws {
        let ipHeader = IPHeader(
            totalLength: .zero,
            headerChecksum: .zero,
            sourceAddress: request.destination,
            destinationAddress: .init(address: (127, 0, 0, 1))
        )
        var icmpHeader = ICMPHeader(
            type: .echoReply,
            code: .zero,
            identifier: request.id,
            sequenceNumber: .zero,
            payload: Payload()
        )
        
        guard let checksum = try? ICMPChecksum()(icmpHeader: icmpHeader) else {
            throw NSError(domain: "Checksum calculation failed", code: .zero)
        }
        icmpHeader.setChecksum(checksum)
        
        var icmpPacket = ICMPPacket(ipHeader: ipHeader, icmpHeader: icmpHeader)
        let data = Data(bytes: &icmpPacket, count: MemoryLayout<ICMPPacket>.size)
        
        pinger.packetSender(packetSender: packetSender, didReceive: data)
    }
    
    func simulateErrorResponse(for request: Request, error: ICMPResponseValidationError) {
        let ipHeader = IPHeader(
            totalLength: .zero,
            headerChecksum: .min,
            sourceAddress: request.destination,
            destinationAddress: request.destination
        )
        let data: Data
        
        switch error {
        case .checksumMismatch(let icmpHeader):
            var icmp = ICMPPacket(ipHeader: ipHeader, icmpHeader: icmpHeader)
            data = Data(bytes: &icmp, count: MemoryLayout<ICMPPacket>.size)
        case .invalidCode(let icmpHeader):
            var icmp = ICMPPacket(ipHeader: ipHeader, icmpHeader: icmpHeader)
            data = Data(bytes: &icmp, count: MemoryLayout<ICMPPacket>.size)
        case .invalidPayload(let icmpHeader):
            var icmp = ICMPPacket(ipHeader: ipHeader, icmpHeader: icmpHeader)
            data = Data(bytes: &icmp, count: MemoryLayout<ICMPPacket>.size)
        case .invalidType(let icmpHeader):
            var icmp = ICMPPacket(ipHeader: ipHeader, icmpHeader: icmpHeader)
            data = Data(bytes: &icmp, count: MemoryLayout<ICMPPacket>.size)
        case .missedIpHeader, .missedIcmpHeader:
            data = Data()
        }
        
        pinger.packetSender(packetSender: packetSender, didReceive: data)
    }
}
