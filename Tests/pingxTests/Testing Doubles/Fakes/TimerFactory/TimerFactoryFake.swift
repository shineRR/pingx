import Foundation
@testable import pingx

// MARK: - TimerFactoryFake

final class TimerFactoryFake: TimerFactory {
    
    // MARK: Properties
    
    private(set) var timer: Timer?
    
    // MARK: Methods
    
    func create(
        timeInterval: TimeInterval,
        repeats: Bool,
        block: @escaping (Timer) -> Void
    ) -> Timer {
        let timer = Timer(timeInterval: timeInterval, repeats: repeats, block: block)
        self.timer = timer
        return timer
    }
}
