// MARK: PingxTimer

protocol PingxTimer {
    var isCancelled: Bool { get }

    func start()
    func stop()
    func fire()
}
