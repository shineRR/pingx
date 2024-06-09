import XCTest
@testable import pingx

// MARK: - PacketSenderTests

final class PacketSenderTests: XCTestCase {
    
    // MARK: Properties
    
    private var pinger: MockPinger!
    private var packetFactory: PacketFactoryFake!
    private var socketFactory: SocketFactoryFake!
    private var packetSender: PacketSenderImpl!
    
    // MARK: Override
    
    override func setUp() {
        super.setUp()
        socketFactory = SocketFactoryFake()
        packetFactory = PacketFactoryFake()
        packetSender = PacketSenderImpl(socketFactory: socketFactory, packetFactory: packetFactory)
        pinger = MockPinger(packetSender: packetSender)
    }
    
    override func tearDown() {
        super.tearDown()
        socketFactory = nil
        packetSender = nil
        pinger = nil
    }
    
    // MARK: Tests
    
    func testPacketSender_socketCreationError() {
        socketFactory.error = .socketCreationError
        let request = Request(destination: Constants.ipv4)
        
        pinger.ping(request: request)
        
        XCTAssertNotNil(pinger.receivedError)
        
        guard let error = pinger.receivedError as? PacketSenderError else {
            XCTFail("Expected to have an error")
            return
        }
        
        XCTAssertEqual(error, socketFactory.error)
        XCTAssertFalse(socketFactory.socket.sendInvoked)
    }
    
    func testPacketSender_invalidate() {
        let request = Request(destination: Constants.ipv4)
        
        pinger.ping(request: request)
        pinger = nil
        packetSender = nil
        
        XCTAssertTrue(socketFactory.socket.invalidateInvoked)
    }
    
    func testPacketSender_socketError() {
        let request = Request(destination: Constants.ipv4)
        let errors: [CFSocketError] = [.error, .timeout]
        let expectedPacketSenderErrors: [PacketSenderError] = [.error, .timeout]
        
        for index in errors.indices {
            socketFactory.socket.error = errors[index]
            pinger.ping(request: request)
            
            guard let error = pinger.receivedError as? PacketSenderError else {
                XCTFail("Expected to have an error")
                return
            }
            
            XCTAssertEqual(error, expectedPacketSenderErrors[index])
        }
    }
    
    func testPacketSender_commandInvocation() {
        let request = Request(destination: Constants.ipv4)
        let data = Data()
        
        pinger.ping(request: request)
        socketFactory.socket.command?.closure(data)
        
        XCTAssertTrue(socketFactory.socket.sendInvoked)
        XCTAssertTrue(pinger.didReceiveInvoked)
        XCTAssertEqual(pinger.didReceiveData, data)
    }
    
    func testPacketSender_packet_creation_error() {
        let request = Request(destination: Constants.ipv4)
        
        packetFactory.error = ICMPChecksum.ChecksumError.outOfBounds
        pinger.ping(request: request)
        
        XCTAssertFalse(socketFactory.socket.sendInvoked)
        XCTAssertNotNil(pinger.receivedError)
        XCTAssertEqual(pinger.receivedError as? PacketSenderError, PacketSenderError.error)
        XCTAssertNil(pinger.didReceiveData)
    }
}

// MARK: - Constants

private extension PacketSenderTests {
    enum Constants {
        static var ipv4: IPv4Address { .init(address: (8, 8, 8, 8)) }
    }
}
