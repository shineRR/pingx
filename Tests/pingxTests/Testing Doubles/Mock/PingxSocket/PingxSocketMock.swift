import Foundation
@testable import pingx

// MARK: - PingxSocketMock

final class PingxSocketMock: PingxSocket {
    typealias Instance = CommandBlock<Data>
    
    var sendReturnValue: CFSocketError!
    private(set) var sendInvocations: [(address: CFData, data: CFData, timeout: CFTimeInterval)] = []
    private(set) var sendCalledCount: Int = 0
    private(set) var invalidateCalledCount: Int = 0
    
    func send(address: CFData, data: CFData, timeout: CFTimeInterval) -> CFSocketError {
        sendCalledCount += 1
        sendInvocations.append((address, data, timeout))
        return sendReturnValue
    }
    
    func invalidate() {
        invalidateCalledCount += 1
    }
}
