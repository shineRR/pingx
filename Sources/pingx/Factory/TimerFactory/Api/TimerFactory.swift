import Foundation

// MARK: - TimerFactory

// sourcery: AutoMockable
protocol TimerFactory {
    func createDispatchSourceTimer(
        timeInterval: TimeInterval,
        eventQueue: DispatchQueue,
        eventHandler: @escaping () -> Void
    ) -> PingxTimer
}
