import Foundation
@testable import pingx

// MARK: - PacketSenderMock

final class PacketSenderMock: PacketSender {
    
    // MARK: Delegate
    
    weak var delegate: PacketSenderDelegate?
    
    // MARK: Properties

    var sendError: Error?
    private(set) var sendCalledCount: Int = 0
    private(set) var sendCalledInvocation: [Request] = []
    private(set) var invalidateCalledCount: Int = 0
    
    func send(_ request: Request) throws {
        sendCalledCount += 1
        sendCalledInvocation.append(request)
        
        if let sendError { throw sendError }
    }
    
    func invalidate() {
        invalidateCalledCount += 1
    }
}
