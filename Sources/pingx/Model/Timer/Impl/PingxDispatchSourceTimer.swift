import Foundation

// MARK: - PingxDispatchSourceTimer

final class PingxDispatchSourceTimer: PingxTimer {
    var isCancelled: Bool {
        eventQueue.sync {
            dispatchTimer?.isCancelled ?? true
        }
    }

    private var dispatchTimer: DispatchSourceTimer?
    private let timeinterval: TimeInterval
    private let eventQueue: DispatchQueue
    private let eventHandler: () -> Void
    
    init(
        timeInterval: TimeInterval,
        eventQueue: DispatchQueue,
        eventHandler: @escaping () -> Void
    ) {
        self.timeinterval = timeInterval
        self.eventQueue = eventQueue
        self.eventHandler = eventHandler
    }

    func start() {
        guard dispatchTimer == nil else { return }
        
        dispatchTimer = DispatchSource.makeTimerSource(queue: eventQueue)
        dispatchTimer?.schedule(deadline: .now(), repeating: timeinterval)
        dispatchTimer?.setEventHandler(
            handler: DispatchWorkItem(block: eventHandler)
        )
        dispatchTimer?.resume()
    }
    
    func stop() {
        dispatchTimer?.cancel()
        dispatchTimer = nil
    }
    
    func fire() {
        eventHandler()
    }
}
