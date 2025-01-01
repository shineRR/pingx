import Foundation
@testable import pingx

// MARK: - PacketSenderMock

final class PacketSenderMock: PacketSender {
    
    // MARK: Delegate
    
    weak var delegate: PacketSenderDelegate?
    
    // MARK: Properties

    var prepareSocketIfNeededError: Error?
    private(set) var prepareSocketIfNeededCalledCount: Int = 0
    private(set) var sendCalledCount: Int = 0
    private(set) var sendCalledInvocation: [Request] = []
    private(set) var invalidateCalledCount: Int = 0
    
    func prepareSocketIfNeeded() throws {
        prepareSocketIfNeededCalledCount += 1
        
        if let prepareSocketIfNeededError { throw prepareSocketIfNeededError }
    }

    func send(_ request: Request) {
        sendCalledCount += 1
        sendCalledInvocation.append(request)
    }
    
    func invalidate() {
        invalidateCalledCount += 1
    }
}
