import XCTest
@testable import pingx

// MARK: - PingerTests

final class PingerTests: XCTestCase {
    
    // MARK: Properties
    
    private var timerFactory: TimerFactoryFake!
    private var responseReceiver: ResponseReceiver!
    private var packetSender: PacketSenderFake!
    private var pinger: ContinuousPinger!
    
    // MARK: Override
    
    override func setUp() {
        super.setUp()
        timerFactory = TimerFactoryFake()
        responseReceiver = ResponseReceiver()
        packetSender = PacketSenderFake()
        pinger = ContinuousPinger(
            configuration: .init(interval: .seconds(.zero)),
            packetSender: packetSender,
            timerFactory: timerFactory
        )
        pinger.delegate = responseReceiver
    }
    
    override func tearDown() {
        super.tearDown()
        timerFactory = nil
        responseReceiver = nil
        packetSender = nil
        pinger = nil
    }
    
    // MARK: Tests
    
    func testPinger_stop() {
        let timeoutInterval = 5
        let request = Request(
            destination: Constants.ipv4,
            timeoutInterval: TimeInterval(timeoutInterval),
            demand: .unlimited
        )
        pinger.ping(request: request)
        pinger.stop(ipv4Address: Constants.ipv4)
        
        for _ in 0..<timeoutInterval {
            timerFactory.timer?.fire()
        }
        
        XCTAssertTrue(responseReceiver.receivedErrors.isEmpty)
        XCTAssertTrue(responseReceiver.receivedResponse.isEmpty)
    }
    
    func testPinger_timerInvalidation() {
        let request = Request(
            destination: Constants.ipv4,
            demand: .max(1)
        )
        
        pinger.ping(request: request)
        
        XCTAssertFalse(timerFactory.timer!.isValid)
    }
}

// MARK: - Demand Tests

extension PingerTests {
    func testPinger_noDemand() {
        let request = Request(
            destination: Constants.ipv4,
            demand: .none
        )
        
        pinger.ping(request: request)
        
        XCTAssertEqual(responseReceiver.receivedErrors.count, .zero)
        XCTAssertEqual(responseReceiver.receivedResponse.count, .zero)
    }
    
    func testPinger_limitedDemand() {
        let demandValue = 3
        let eventsExpectation = XCTestExpectation()
        eventsExpectation.expectedFulfillmentCount = demandValue + 1
        eventsExpectation.isInverted = true
        responseReceiver.expectation = eventsExpectation
        
        let request = Request(
            destination: Constants.ipv4,
            demand: .max(demandValue)
        )
        pinger.ping(request: request)
        
        
        wait(for: [eventsExpectation], timeout: 0.1)
        XCTAssertEqual(responseReceiver.receivedErrors.count, .zero)
        XCTAssertEqual(responseReceiver.receivedResponse.count, demandValue)
    }
    
    func testPinger_unlimitedDemand() {
        let request = Request(
            destination: Constants.ipv4,
            demand: .unlimited
        )
        
        pinger.ping(request: request)
        pinger.ping(request: request)
        
        XCTAssertFalse(responseReceiver.receivedErrors.isEmpty)
        XCTAssertEqual(responseReceiver.receivedErrors.last, .isOutgoing)
    }
}

// MARK: - Error Tests

extension PingerTests {
    func testPinger_timeout() {
        let timeoutInterval = 5
        let request = Request(
            destination: Constants.ipv4,
            timeoutInterval: TimeInterval(timeoutInterval),
            demand: .unlimited
        )
        
        pinger.ping(request: request)
        
        for _ in 0..<timeoutInterval {
            timerFactory.timer?.fire()
        }
        
        XCTAssertFalse(responseReceiver.receivedErrors.isEmpty)
        XCTAssertEqual(responseReceiver.receivedErrors.last, .timeout)
    }
    
    func testPinger_socketError() {
        packetSender.error = .socketCreationError
        
        let request = Request(destination: Constants.ipv4)
        pinger.ping(request: request)
        
        XCTAssertFalse(responseReceiver.receivedErrors.isEmpty)
        XCTAssertEqual(responseReceiver.receivedErrors.last, .socketFailed)
    }
    
    func testPinger_missedIpHeader() {
        packetSender.validationError = .missedIpHeader
        
        let request = Request(destination: Constants.ipv4)
        pinger.ping(request: request)
        
        XCTAssertTrue(responseReceiver.receivedResponse.isEmpty)
        XCTAssertTrue(responseReceiver.receivedErrors.isEmpty)
    }
    
    func testPinger_invalidResponseStructure() {
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
        let request = Request(destination: Constants.ipv4)
        
        for index in validationErrors.indices {
            packetSender.validationError = validationErrors[index]
            pinger.ping(request: request)
            XCTAssertEqual(responseReceiver.receivedErrors.count, index + 1)
            XCTAssertEqual(responseReceiver.receivedErrors[index], .invalidResponseStructure)
        }
    }
}

// MARK: - Constants

private extension PingerTests {
    enum Constants {
        static var ipv4: IPv4Address { .init(address: (8, 8, 8, 8)) }
    }
}
