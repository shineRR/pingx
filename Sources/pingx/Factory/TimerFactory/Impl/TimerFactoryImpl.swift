import Foundation

// MARK: - TimerFactoryImpl

final class TimerFactoryImpl: TimerFactory {
    func createDispatchSourceTimer(
        timeInterval: TimeInterval,
        eventQueue: DispatchQueue,
        eventHandler: @escaping () -> Void
    ) -> PingxTimer {
        PingxDispatchSourceTimer(
            timeInterval: timeInterval,
            eventQueue: eventQueue,
            eventHandler: eventHandler
        )
    }
}
