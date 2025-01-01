import Foundation

// MARK: - TimerFactory

protocol TimerFactory {
    func createDispatchSourceTimer(
        timeInterval: TimeInterval,
        eventQueue: DispatchQueue,
        eventHandler: @escaping () -> Void
    ) -> PingxTimer
}
