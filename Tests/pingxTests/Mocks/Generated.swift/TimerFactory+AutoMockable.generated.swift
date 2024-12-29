// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import pingx

class TimerFactoryMock: TimerFactory {

    //MARK: - create

    var createTimeIntervalRepeatsBlockCallsCount = 0
    var createTimeIntervalRepeatsBlockCalled: Bool {
        return createTimeIntervalRepeatsBlockCallsCount > 0
    }
    var createTimeIntervalRepeatsBlockReceivedArguments: (timeInterval: TimeInterval, repeats: Bool, block: (Timer) -> Void)?
    var createTimeIntervalRepeatsBlockReceivedInvocations: [(timeInterval: TimeInterval, repeats: Bool, block: (Timer) -> Void)] = []
    var createTimeIntervalRepeatsBlockReturnValue: Timer!
    var createTimeIntervalRepeatsBlockClosure: ((TimeInterval, Bool, @Sendable @escaping (Timer) -> Void) -> Timer)?

    func create(timeInterval: TimeInterval, repeats: Bool, block: @Sendable @escaping (Timer) -> Void) -> Timer {
        createTimeIntervalRepeatsBlockCallsCount += 1
        createTimeIntervalRepeatsBlockReceivedArguments = (timeInterval: timeInterval, repeats: repeats, block: block)
        createTimeIntervalRepeatsBlockReceivedInvocations.append((timeInterval: timeInterval, repeats: repeats, block: block))
        return createTimeIntervalRepeatsBlockClosure.map({ $0(timeInterval, repeats, block) }) ?? createTimeIntervalRepeatsBlockReturnValue
    }

}
