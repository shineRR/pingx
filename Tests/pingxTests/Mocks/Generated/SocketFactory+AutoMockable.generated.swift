// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import pingx

class SocketFactoryMock: SocketFactory {

    //MARK: - create

    var createThrowableError: (any Error)?
    var createCallsCount = 0
    var createCalled: Bool {
        return createCallsCount > 0
    }
    var createReceivedCommand: (CommandBlock<Data>)?
    var createReceivedInvocations: [(CommandBlock<Data>)] = []
    var createReturnValue: (any PingxSocket)!
    var createClosure: ((CommandBlock<Data>) throws -> any PingxSocket)?

    func create(command: CommandBlock<Data>) throws -> any PingxSocket {
        createCallsCount += 1
        createReceivedCommand = command
        createReceivedInvocations.append(command)
        if let error = createThrowableError {
            throw error
        }
        if let createClosure = createClosure {
            return try createClosure(command)
        } else {
            return createReturnValue
        }
    }

}

// swiftlint:enable all
