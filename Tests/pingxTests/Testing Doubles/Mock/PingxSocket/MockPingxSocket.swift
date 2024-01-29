import Foundation
@testable import pingx

// MARK: - MockPingxSocket

final class MockPingxSocket: PingxSocket {

    // MARK: Typealias
    
    typealias Instance = AnyObject
   
    // MARK: Properties
    
    var error: CFSocketError = .success
    var command: CommandBlock<Data>?
    private(set) var sendInvoked = false
    private(set) var invalidateInvoked = false
    
    // MARK: Methods
    
    func send(address: CFData, data: CFData, timeout: CFTimeInterval) -> CFSocketError {
        sendInvoked = true
        return error
    }
    
    func invalidate() {
        invalidateInvoked = true
    }
}
