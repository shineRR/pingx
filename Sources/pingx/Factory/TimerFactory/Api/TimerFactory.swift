import Foundation

// MARK: - TimerFactory

protocol TimerFactory {
    func create(timeInterval: TimeInterval, repeats: Bool, block: @Sendable @escaping (Timer) -> Void) -> Timer
}
