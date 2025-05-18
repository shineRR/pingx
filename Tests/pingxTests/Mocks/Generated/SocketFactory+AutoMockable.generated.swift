// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import pingx

final class SocketFactoryMock: SocketFactoryProtocol {

    // MARK: - make

    var makeThrowableError: (any Error)?
    var makeCallsCount = 0
    var makeCalled: Bool {
        return makeCallsCount > 0
    }
    var makeReceivedCommand: (CommandBlock<Data>)?
    var makeReceivedInvocations: [(CommandBlock<Data>)] = []
    var makeReturnValue: (any PingxSocket)!
    var makeClosure: ((CommandBlock<Data>) throws -> any PingxSocket)?

    func make(command: CommandBlock<Data>) throws -> any PingxSocket {
        makeCallsCount += 1
        makeReceivedCommand = command
        makeReceivedInvocations.append(command)
        if let error = makeThrowableError {
            throw error
        }
        if let makeClosure = makeClosure {
            return try makeClosure(command)
        } else {
            return makeReturnValue
        }
    }

}

// swiftlint:enable all
