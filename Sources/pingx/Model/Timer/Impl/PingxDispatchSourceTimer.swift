import Foundation

// MARK: - PingxDispatchSourceTimer

final class PingxDispatchSourceTimer: PingxTimer {
    var isCancelled: Bool {
        timerQueue.sync {
            dispatchTimer?.isCancelled ?? true
        }
    }

    private var dispatchTimer: DispatchSourceTimer?
    private let timerQueue = DispatchQueue(label: "com.pingx.DispatchSourceTimer.queue")
    private let timeinterval: TimeInterval
    private let eventHandler: () -> Void
    
    init(timeInterval: TimeInterval, eventHandler: @escaping () -> Void) {
        self.timeinterval = timeInterval
        self.eventHandler = eventHandler
    }

    func start() {
        timerQueue.async { [weak self] in
            guard let self else { return }

            self.dispatchTimer?.cancel()

            self.dispatchTimer = DispatchSource.makeTimerSource(queue: self.timerQueue)
            self.dispatchTimer?.schedule(deadline: .now(), repeating: timeinterval)
            self.dispatchTimer?.setEventHandler(
                handler: DispatchWorkItem(block: eventHandler)
            )
            self.dispatchTimer?.resume()
        }
    }

    func stop() {
        timerQueue.async { [weak self] in
            guard let self = self else { return }

            self.dispatchTimer?.cancel()
            self.dispatchTimer = nil
        }
    }
    
    func fire() {
        eventHandler()
    }
}
