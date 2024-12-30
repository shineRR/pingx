import Foundation

// MARK: - TimerFactory

protocol TimerFactory {
    func createDispatchSourceTimer(
        timeInterval: TimeInterval,
        eventHandler: @escaping () -> Void
    ) -> PingxTimer
}
