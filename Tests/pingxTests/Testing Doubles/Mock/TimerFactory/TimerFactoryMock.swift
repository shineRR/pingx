import Foundation
@testable import pingx

// MARK: - TimerFactoryFake

final class TimerFactoryMock: TimerFactory {
    var createDispatchSourceTimerReturnValue: PingxTimer!
    private(set) var createDispatchSourceTimerCalledCount: Int = 0
    private(set) var createDispatchSourceTimerInvocations: [(timeInterval: TimeInterval, eventHandler: () -> Void)] = []
    
    func createDispatchSourceTimer(
        timeInterval: TimeInterval,
        eventQueue: DispatchQueue,
        eventHandler: @escaping () -> Void
    ) -> PingxTimer {
        createDispatchSourceTimerCalledCount += 1
        createDispatchSourceTimerInvocations.append((timeInterval, eventHandler))
        return createDispatchSourceTimerReturnValue
    }
}
