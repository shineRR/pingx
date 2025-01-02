// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import pingx

class PingxTimerMock: PingxTimer {

    // MARK: - start

    var startCallsCount = 0
    var startCalled: Bool {
        return startCallsCount > 0
    }
    var startClosure: (() -> Void)?

    func start() {
        startCallsCount += 1
        startClosure?()
    }

    // MARK: - stop

    var stopCallsCount = 0
    var stopCalled: Bool {
        return stopCallsCount > 0
    }
    var stopClosure: (() -> Void)?

    func stop() {
        stopCallsCount += 1
        stopClosure?()
    }

    // MARK: - fire

    var fireCallsCount = 0
    var fireCalled: Bool {
        return fireCallsCount > 0
    }
    var fireClosure: (() -> Void)?

    func fire() {
        fireCallsCount += 1
        fireClosure?()
    }

}

// swiftlint:enable all
