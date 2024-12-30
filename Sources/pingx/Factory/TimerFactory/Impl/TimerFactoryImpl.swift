import Foundation

// MARK: - TimerFactoryImpl

final class TimerFactoryImpl: TimerFactory {
    func createDispatchSourceTimer(
        timeInterval: TimeInterval,
        eventHandler: @escaping () -> Void
    ) -> PingxTimer {
        PingxDispatchSourceTimer(
            timeInterval: timeInterval,
            eventHandler: eventHandler
        )
    }
}
