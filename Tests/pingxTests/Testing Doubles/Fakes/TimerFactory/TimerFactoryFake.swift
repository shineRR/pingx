import Foundation
@testable import pingx

// MARK: - TimerFactoryFake

final class TimerFactoryFake: TimerFactory {
    
    // MARK: Properties
    
    private(set) var timer: PingxTimer?
    
    // MARK: Methods
    
    func createDispatchSourceTimer(
        timeInterval: TimeInterval,
        eventHandler: @escaping () -> Void
    ) -> PingxTimer {
        let timer = PingxDispatchSourceTimer(timeInterval: timeInterval, eventHandler: eventHandler)
        self.timer = timer
        return timer
    }
}
