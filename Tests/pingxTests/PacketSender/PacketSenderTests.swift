import XCTest
@testable import pingx

// MARK: - PacketSenderTests

final class PacketSenderTests: XCTestCase {
    
    // MARK: Properties

    private var socket: PingxSocketMock!
    private var packetFactory: PacketFactoryMock!
    private var socketFactory: SocketFactoryMock!
    private var packetSenderDelegate: PacketSenderDelegateMock!
    private var packetSender: PacketSenderImpl!
    
    // MARK: Override
    
    override func setUp() {
        super.setUp()
        socket = PingxSocketMock()
        socket.sendReturnValue = .success
        
        socketFactory = SocketFactoryMock()
        socketFactory.socketCreateReturnValue = socket
        
        packetFactory = PacketFactoryMock()
        packetSenderDelegate = PacketSenderDelegateMock()
        packetSender = PacketSenderImpl(socketFactory: socketFactory, packetFactory: packetFactory)
        packetSender.delegate = packetSenderDelegate
    }
    
    override func tearDown() {
        super.tearDown()
        socketFactory = nil
        packetSender = nil
    }
    
    // MARK: Tests
    
    func test_send_whenResponseReceived_notifiesDelegate() throws {
        let request = Request(destination: Constants.ipv4)
        let data = Data()
        
        try packetSender.send(request)
        socketFactory.socketCreateInvocations.last?.closure(data)
        
        XCTAssertEqual(socketFactory.socketCreateCalledCount, 1)
        XCTAssertEqual(packetFactory.packetCreateInvocations, [.icmp])
        XCTAssertEqual(socket.sendCalledCount, 1)
        XCTAssertEqual(packetSenderDelegate.packetSenderCalledCount, 1)
        XCTAssertTrue(packetSenderDelegate.packetSenderInvocations[0].packetSender === packetSender)
        XCTAssertEqual(packetSenderDelegate.packetSenderInvocations[0].data, data)
    }
    
    func test_send_whenSocketAlreadyCreated_doesNotCreateSocket() throws {
        let request = Request(destination: Constants.ipv4)
        
        try packetSender.send(request)
        try packetSender.send(request)
        
        XCTAssertEqual(socketFactory.socketCreateCalledCount, 1)
    }
    
    func test_send_whenSocketCreationFailed_throwsError() {
        let request = Request(destination: Constants.ipv4)
        
        socketFactory.error = .socketCreationError

        XCTAssertThrowsError(try packetSender.send(request)) { error in
            guard let error = error as? PacketSenderError else {
                XCTFail("Expected to have an error")
                return
            }
            
            XCTAssertEqual(error, .socketCreationError)
            XCTAssertEqual(socket.sendCalledCount, 0)
        }
    }
    
    func test_send_whenSocketFailed_throwsError() {
        let request = Request(destination: Constants.ipv4)
        let errors: [CFSocketError] = [.error, .timeout]
        let expectedPacketSenderErrors: [PacketSenderError] = [.error, .timeout]
        
        for index in errors.indices {
            socket.sendReturnValue = errors[index]
            
            XCTAssertThrowsError(try packetSender.send(request)) { error in
                guard let error = error as? PacketSenderError else {
                    XCTFail("Expected to have an error")
                    return
                }
                
                XCTAssertEqual(error, expectedPacketSenderErrors[index])
            }
        }
    }
    
    func test_send_packetCreationFailed_throwsError() throws {
        let request = Request(destination: Constants.ipv4)
        
        packetFactory.error = ICMPChecksum.ChecksumError.outOfBounds
        
        XCTAssertThrowsError(try packetSender.send(request)) { error in
            guard let error = error as? PacketSenderError else {
                XCTFail("Expected to have an error")
                return
            }
            
            XCTAssertEqual(error, .error)
            XCTAssertEqual(socket.sendCalledCount, 0)
            XCTAssertEqual(packetSenderDelegate.packetSenderCalledCount, 0)
        }
    }
    
    func test_invalidate() throws {
        let request = Request(destination: Constants.ipv4)
        try packetSender.send(request)

        packetSender = nil
        
        XCTAssertEqual(socket.invalidateCalledCount, 1)
    }
}

// MARK: - Constants

private extension PacketSenderTests {
    enum Constants {
        static var ipv4: IPv4Address { .init(address: (8, 8, 8, 8)) }
    }
}
