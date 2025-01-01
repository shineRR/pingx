@testable import pingx

// MARK: - PingxTimerMock

final class PingxTimerMock: PingxTimer {
    private(set) var isCancelled: Bool = true
    private(set) var startCallCount: Int = 0
    private(set) var stopCallCount: Int = 0
    private(set) var fireCallCount: Int = 0

    func start() {
        isCancelled = false
        startCallCount += 1
    }
    
    func stop() {
        isCancelled = true
        stopCallCount += 1
    }
    
    func fire() {
        fireCallCount += 1
    }
}
