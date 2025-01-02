// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import pingx

class TimerFactoryMock: TimerFactory {

    //MARK: - createDispatchSourceTimer

    var createDispatchSourceTimerCallsCount = 0
    var createDispatchSourceTimerCalled: Bool {
        return createDispatchSourceTimerCallsCount > 0
    }
    var createDispatchSourceTimerReceivedArguments: (timeInterval: TimeInterval, eventQueue: DispatchQueue, eventHandler: () -> Void)?
    var createDispatchSourceTimerReceivedInvocations: [(timeInterval: TimeInterval, eventQueue: DispatchQueue, eventHandler: () -> Void)] = []
    var createDispatchSourceTimerReturnValue: PingxTimer!
    var createDispatchSourceTimerClosure: ((TimeInterval, DispatchQueue, @escaping () -> Void) -> PingxTimer)?

    func createDispatchSourceTimer(timeInterval: TimeInterval, eventQueue: DispatchQueue, eventHandler: @escaping () -> Void) -> PingxTimer {
        createDispatchSourceTimerCallsCount += 1
        createDispatchSourceTimerReceivedArguments = (timeInterval: timeInterval, eventQueue: eventQueue, eventHandler: eventHandler)
        createDispatchSourceTimerReceivedInvocations.append((timeInterval: timeInterval, eventQueue: eventQueue, eventHandler: eventHandler))
        if let createDispatchSourceTimerClosure = createDispatchSourceTimerClosure {
            return createDispatchSourceTimerClosure(timeInterval, eventQueue, eventHandler)
        } else {
            return createDispatchSourceTimerReturnValue
        }
    }

}

// swiftlint:enable all
