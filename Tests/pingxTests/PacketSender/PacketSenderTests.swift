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
        socketFactory.socketCreateReturnValue = socket
        
        packetFactory = PacketFactoryMock()
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
        socketFactory.socketCreateInvocations.last?.closure(data)
        
        XCTAssertEqual(socketFactory.socketCreateCalledCount, 1)
        XCTAssertEqual(packetFactory.packetCreateInvocations[0].identifier, request.id)
        XCTAssertEqual(packetFactory.packetCreateInvocations[0].type, .icmp)
        XCTAssertEqual(socket.sendCalledCount, 1)
        XCTAssertEqual(packetSenderDelegate.packetSenderDidReceiveDataCalledCount, 1)
        XCTAssertTrue(packetSenderDelegate.packetSenderDidReceiveDataInvocations[0].packetSender === packetSender)
        XCTAssertEqual(packetSenderDelegate.packetSenderDidReceiveDataInvocations[0].data, data)
    }
    
    func test_send_whenSocketAlreadyCreated_doesNotCreateSocket() {
        let request = Request(destination: Constants.ipv4)
        
        packetSender.send(request)
        packetSender.send(request)
        
        XCTAssertEqual(socketFactory.socketCreateCalledCount, 1)
    }
    
    func test_send_whenSocketCreationFailed_throwsError() throws {
        let request = Request(destination: Constants.ipv4)
        
        socketFactory.error = .socketCreationError
        packetSender.send(request)
        
        XCTAssertEqual(packetSenderDelegate.packetSenderDidCompleteWithErrorCalledCount, 1)
        XCTAssertTrue(packetSenderDelegate.packetSenderDidCompleteWithErrorInvocations[0].packetSender === packetSender)
        XCTAssertEqual(packetSenderDelegate.packetSenderDidCompleteWithErrorInvocations[0].request, request)
        XCTAssertEqual(packetSenderDelegate.packetSenderDidCompleteWithErrorInvocations[0].error, .socketCreationError)
        XCTAssertEqual(socket.sendCalledCount, 0)
    }
    
    func test_send_whenSocketFailed_throwsError() {
        let request = Request(destination: Constants.ipv4)
        let errors: [CFSocketError] = [.error, .timeout]
        let expectedPacketSenderErrors: [PacketSenderError] = [.error, .timeout]
        
        for index in errors.indices {
            socket.sendReturnValue = errors[index]
            packetSender.send(request)
            
            XCTAssertEqual(
                packetSenderDelegate.packetSenderDidCompleteWithErrorInvocations[index].error,
                expectedPacketSenderErrors[index]
            )
        }
    }
    
    func test_send_packetCreationFailed_throwsError() throws {
        let request = Request(destination: Constants.ipv4)
        
        packetFactory.error = ICMPChecksum.ChecksumError.outOfBounds
        packetSender.send(request)
        
        XCTAssertEqual(packetSenderDelegate.packetSenderDidCompleteWithErrorCalledCount, 1)
        XCTAssertTrue(packetSenderDelegate.packetSenderDidCompleteWithErrorInvocations[0].packetSender === packetSender)
        XCTAssertEqual(packetSenderDelegate.packetSenderDidCompleteWithErrorInvocations[0].request, request)
        XCTAssertEqual(packetSenderDelegate.packetSenderDidCompleteWithErrorInvocations[0].error, .unableToCreatePacket)
        XCTAssertEqual(socket.sendCalledCount, 0)
    }
    
    func test_invalidate() throws {
        let request = Request(destination: Constants.ipv4)
        packetSender.send(request)

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
