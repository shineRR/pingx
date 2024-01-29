import Foundation
@testable import pingx

// MARK: - SocketFactoryFake

final class SocketFactoryFake: SocketFactory {
    
    // MARK: Properties
    
    private(set) var socket = MockPingxSocket()
    var error: PacketSenderError?
    
    // MARK: Methods
    
    func create(command: CommandBlock<Data>) throws -> any PingxSocket {
        if let error { throw error }
        socket.command = command
        return socket
    }
}
