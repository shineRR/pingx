import Foundation

// MARK: - TimerFactoryImpl

final class TimerFactoryImpl: TimerFactory {
    func create(
        timeInterval: TimeInterval,
        repeats: Bool,
        block: @Sendable @escaping (Timer) -> Void
    ) -> Timer {
        .init(timeInterval: timeInterval, repeats: repeats, block: block)
    }
}
