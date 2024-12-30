import XCTest
@testable import pingx

// MARK: - PingerTests

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
            configuration: .init(interval: .seconds(.zero)),
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
        
        XCTAssertEqual(packetSender.sendCalledInvocation, [request])
        XCTAssertEqual(timerFactory.createDispatchSourceTimerCalledCount, 1)
    }
    
    func test_start_whenRequestIsOutgoingAndDemandIsGreaterThanZero_returnsIsOutgoingError() {
        let request = Request(destination: Constants.ipv4, demand: .max(1))

        pinger.ping(request: request)
        pinger.ping(request: request)
        
        XCTAssertEqual(packetSender.sendCalledInvocation, [request])
        XCTAssertEqual(timerFactory.createDispatchSourceTimerCalledCount, 1)
        XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorCalledCount, 1)
        XCTAssertTrue(pingerDelegate.pingerDidCompleteWithErrorInvocations[0].pinger === pinger)
        XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorInvocations[0].error, .isOutgoing)
        XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorInvocations[0].request, request)
    }
    
    func test_start_whenDemandIsZero_doesNotSendRequest() {
        let request = Request(destination: Constants.ipv4, demand: .max(0))

        pinger.ping(request: request)
        
        XCTAssertEqual(packetSender.sendCalledCount, 0)
        XCTAssertEqual(timerFactory.createDispatchSourceTimerCalledCount, 0)
    }
    
    func test_start_whenSendRequestReturnsError_notifiesDelegate() {
        let request = Request(destination: Constants.ipv4)

        packetSender.sendError = PacketSenderError.error
        pinger.ping(request: request)
        
        XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorCalledCount, 1)
        XCTAssertTrue(pingerDelegate.pingerDidCompleteWithErrorInvocations[0].pinger === pinger)
        XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorInvocations[0].error, .socketFailed)
        XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorInvocations[0].request, request)
        XCTAssertTrue(timer.isCancelled)
    }

    func test_stop_invalidatesTimer() {
        let request = Request(destination: Constants.ipv4)
        
        pinger.ping(request: request)
        pinger.stop(ipv4Address: request.destination)
        
        XCTAssertTrue(timer.isCancelled)
    }
    
    func test_stop_whenResponseReceived_doesNotNotifyDelegate() {
        let request = Request(destination: Constants.ipv4)
        
        pinger.ping(request: request)
        pinger.stop(ipv4Address: request.destination)
        simulateValidResponse(for: request)
        
        XCTAssertEqual(pingerDelegate.pingerDidReceiveResponseCalledCount, 0)
        XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorCalledCount, 0)
    }
}

// MARK: - Demand Tests

extension PingerTests {
    func test_demand_whenZero_doesNotNotifyDelegate() {
        let request = Request(destination: Constants.ipv4, demand: .none)
        
        pinger.ping(request: request)
        
        XCTAssertEqual(pingerDelegate.pingerDidReceiveResponseCalledCount, 0)
        XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorCalledCount, 0)
    }
    
    func test_demand_whenLimited() {
        let demandValue = 2
        let request = Request(destination: Constants.ipv4, demand: .max(demandValue))

        pinger.ping(request: request)

        for index in 0...demandValue {
            simulateValidResponse(for: request)
            
            let doesResponseCountExceedOrEqualDemandValue = (index + 1) >= demandValue
            if !doesResponseCountExceedOrEqualDemandValue {
                let nextSendCalledCount = index + 2
                let expectation = XCTestExpectation(
                    description: "Wait for sendCalledCount to reach \(nextSendCalledCount)"
                )
            
                DispatchQueue.global().async {
                    while self.packetSender.sendCalledCount != nextSendCalledCount {
                        usleep(100000) // 100ms
                    }
                    expectation.fulfill()
                }
                   
                wait(for: [expectation], timeout: 1)
            }
        }
        
        XCTAssertEqual(packetSender.sendCalledCount, 2)
        XCTAssertEqual(pingerDelegate.pingerDidReceiveResponseCalledCount, 2)
        XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorCalledCount, 0)
    }
}

// MARK: - Error Tests

extension PingerTests {
    func test_error_whenRequestIsTimedOut() {
        let timeoutInterval: TimeInterval = 5
        let request = Request(destination: Constants.ipv4, timeoutInterval: timeoutInterval)
        
        pinger.ping(request: request)
        
        for _ in 0..<Int(timeoutInterval) {
            timerFactory.createDispatchSourceTimerInvocations.last?.eventHandler()
        }
        
        XCTAssertEqual(pingerDelegate.pingerDidReceiveResponseCalledCount, 0)
        XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorCalledCount, 1)
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

    func test_error_invalidResponseStructure() {
        let ipHeader = IPHeader(
            totalLength: .zero,
            headerChecksum: .min,
            sourceAddress: Constants.ipv4,
            destinationAddress: Constants.ipv4
        )
        let validationErrors: [ICMPResponseValidationError] = [
            .checksumMismatch(ipHeader),
            .invalidCode(ipHeader),
            .invalidIdentifier(ipHeader),
            .invalidType(ipHeader),
            .missedIcmpHeader(ipHeader)
        ]
        let request = Request(destination: Constants.ipv4, demand: .unlimited)
        
        pinger.ping(request: request)
        
        for (index, error) in validationErrors.enumerated() {
            simulateErrorResponse(for: request, error: error)

            XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorCalledCount, index + 1)
            XCTAssertTrue(pingerDelegate.pingerDidCompleteWithErrorInvocations[index].pinger === pinger)
            XCTAssertEqual(pingerDelegate.pingerDidCompleteWithErrorInvocations[index].request, request)
            XCTAssertEqual(
                pingerDelegate.pingerDidCompleteWithErrorInvocations[index].error,
                .invalidResponseStructure
            )
        }
    }
}

private extension PingerTests {
    func simulateValidResponse(for request: Request) {
        let ipHeader = IPHeader(
            totalLength: .zero,
            headerChecksum: .zero,
            sourceAddress: request.destination,
            destinationAddress: .init(address: (127, 0, 0, 1))
        )
        var icmpHeader = ICMPHeader(
            type: .echoReply,
            code: .zero,
            identifier: .zero,
            sequenceNumber: .zero,
            payload: Payload()
        )
        let checksum = try! ICMPChecksum()(header: icmpHeader)
        icmpHeader.setChecksum(checksum)
        
        var icmpPacket = ICMPPacket(ipHeader: ipHeader, icmpHeader: icmpHeader)
        let data = Data(bytes: &icmpPacket, count: MemoryLayout<ICMPPacket>.size)
        
        pinger.packetSender(packetSender: packetSender, didReceive: data)
    }
    
    func simulateErrorResponse(for request: Request, error: ICMPResponseValidationError) {
        let data: Data
        
        switch error {
        case .checksumMismatch(let ipHeader):
            let icmpHeader = ICMPHeader(
                type: .echoReply,
                code: .zero,
                identifier: .zero,
                sequenceNumber: .zero,
                payload: Payload()
            )

            var icmp = ICMPPacket(ipHeader: ipHeader, icmpHeader: icmpHeader)
            data = Data(bytes: &icmp, count: MemoryLayout<ICMPPacket>.size)
        case .invalidCode(let ipHeader):
            let icmpHeader = ICMPHeader(
                type: .echoReply,
                code: UInt8.random(in: 200...255),
                identifier: .zero,
                sequenceNumber: .zero,
                payload: Payload()
            )

            var icmp = ICMPPacket(ipHeader: ipHeader, icmpHeader: icmpHeader)
            data = Data(bytes: &icmp, count: MemoryLayout<ICMPPacket>.size)
        case .invalidIdentifier(let ipHeader):
            let icmpHeader = ICMPHeader(
                type: .echoReply,
                code: .zero,
                identifier: .zero,
                sequenceNumber: .zero,
                payload: Payload(identifier: (0, 0, 0, 0, 0, 0, 0, 0))
            )

            var icmp = ICMPPacket(ipHeader: ipHeader, icmpHeader: icmpHeader)
            data = Data(bytes: &icmp, count: MemoryLayout<ICMPPacket>.size)
        case .invalidType(let ipHeader):
            let icmpHeader = ICMPHeader(
                type: .routerSolicitation,
                code: .zero,
                identifier: .zero,
                sequenceNumber: .zero,
                payload: Payload()
            )

            var icmp = ICMPPacket(ipHeader: ipHeader, icmpHeader: icmpHeader)
            data = Data(bytes: &icmp, count: MemoryLayout<ICMPPacket>.size)
        case .missedIcmpHeader(var ipHeader):
            data = Data(bytes: &ipHeader, count: MemoryLayout<IPHeader>.size)
        case .missedIpHeader:
            data = Data()
        }
        
        pinger.packetSender(packetSender: packetSender, didReceive: data)
    }
}
