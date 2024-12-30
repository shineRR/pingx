import Foundation
@testable import pingx

// MARK: - SocketFactoryFake

final class SocketFactoryMock: SocketFactory {
    
    // MARK: Properties
    
    private(set) var socketCreateCalledCount: Int = 0
    private(set) var socketCreateInvocations: [CommandBlock<Data>] = []
    var socketCreateReturnValue: (any PingxSocket)!
    var error: PacketSenderError?
    
    // MARK: Methods
    
    func create(command: CommandBlock<Data>) throws -> any PingxSocket {
        socketCreateCalledCount += 1
        socketCreateInvocations.append(command)
        
        if let error { throw error }
        return socketCreateReturnValue
    }
}
