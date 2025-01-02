import XCTest
@testable import pingx

// MARK: - PacketSenderTests

final class PacketSenderTests: XCTestCase {
    
    // MARK: Properties

    private var socket: PingxSocketMock!
    private var socketFactory: SocketFactoryMock!
    private var packetFactory: PacketFactoryMock!
    private var packetSenderDelegate: PacketSenderDelegateMock!
    private var packetSender: PacketSenderImpl!
    
    // MARK: Override
    
    override func setUp() {
        super.setUp()

        socket = PingxSocketMock()
        socket.sendReturnValue = .success
        
        socketFactory = SocketFactoryMock()
        socketFactory.createReturnValue = socket
        
        packetFactory = PacketFactoryMock()
        packetFactory.createReturnValue = PacketMock()

        packetSenderDelegate = PacketSenderDelegateMock()
        packetSender = PacketSenderImpl(socketFactory: socketFactory, packetFactory: packetFactory)
        packetSender.delegate = packetSenderDelegate
    }
    
    override func tearDown() {
        super.tearDown()

        socket = nil
        socketFactory = nil
        packetFactory = nil
        packetSenderDelegate = nil
        packetSender = nil
    }
    
    // MARK: Tests
    
    func test_send_whenResponseReceived_notifiesDelegate() {
        let request = Request(destination: Constants.ipv4)
        let data = Data()
        
        packetSender.send(request)
        socketFactory.createReceivedInvocations.last?.closure(data)
        
        XCTAssertEqual(socketFactory.createCallsCount, 1)
        XCTAssertEqual(packetFactory.createReceivedInvocations[0].identifier, request.id)
        XCTAssertEqual(packetFactory.createReceivedInvocations[0].type, .icmp)
        XCTAssertEqual(socket.sendCallsCount, 1)
        XCTAssertEqual(packetSenderDelegate.didReceiveDataCalledCount, 1)
        XCTAssertTrue(packetSenderDelegate.didReceiveDataInvocations[0].packetSender === packetSender)
        XCTAssertEqual(packetSenderDelegate.didReceiveDataInvocations[0].data, data)
    }
    
    func test_send_whenSocketAlreadyCreated_doesNotCreateSocket() {
        let request = Request(destination: Constants.ipv4)
        
        packetSender.send(request)
        packetSender.send(request)
        
        XCTAssertEqual(socketFactory.createCallsCount, 1)
    }
    
    func test_send_whenSocketCreationFailed_throwsError() throws {
        let request = Request(destination: Constants.ipv4)
        
        socketFactory.createThrowableError = PacketSenderError.socketCreationError
        packetSender.send(request)
        
        XCTAssertEqual(packetSenderDelegate.didCompleteWithErrorCalledCount, 1)
        XCTAssertTrue(packetSenderDelegate.didCompleteWithErrorInvocations[0].packetSender === packetSender)
        XCTAssertEqual(packetSenderDelegate.didCompleteWithErrorInvocations[0].request, request)
        XCTAssertEqual(packetSenderDelegate.didCompleteWithErrorInvocations[0].error, .socketCreationError)
        XCTAssertEqual(socket.sendCallsCount, 0)
    }
    
    func test_send_whenSocketFailed_throwsError() {
        let request = Request(destination: Constants.ipv4)
        let errors: [CFSocketError] = [.error, .timeout]
        let expectedPacketSenderErrors: [PacketSenderError] = [.error, .timeout]
        
        for index in errors.indices {
            socket.sendReturnValue = errors[index]
            packetSender.send(request)
            
            XCTAssertEqual(
                packetSenderDelegate.didCompleteWithErrorInvocations[index].error,
                expectedPacketSenderErrors[index]
            )
        }
    }
    
    func test_send_packetCreationFailed_throwsError() throws {
        let request = Request(destination: Constants.ipv4)
        
        packetFactory.createThrowableError = ICMPChecksum.ChecksumError.outOfBounds
        packetSender.send(request)
        
        XCTAssertEqual(packetSenderDelegate.didCompleteWithErrorCalledCount, 1)
        XCTAssertTrue(packetSenderDelegate.didCompleteWithErrorInvocations[0].packetSender === packetSender)
        XCTAssertEqual(packetSenderDelegate.didCompleteWithErrorInvocations[0].request, request)
        XCTAssertEqual(packetSenderDelegate.didCompleteWithErrorInvocations[0].error, .unableToCreatePacket)
        XCTAssertEqual(socket.sendCallsCount, 0)
    }
    
    func test_deinit_invalidate() throws {
        let request = Request(destination: Constants.ipv4)
        packetSender.send(request)

        packetSender = nil
        
        XCTAssertEqual(socket.invalidateCallsCount, 1)
    }
}

// MARK: - Constants

private extension PacketSenderTests {
    enum Constants {
        static var ipv4: IPv4Address { .init(address: (8, 8, 8, 8)) }
    }
}
