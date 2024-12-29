// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import pingx

class SocketFactoryMock: SocketFactory {

    //MARK: - create

    var createCommandThrowableError: Error?
    var createCommandCallsCount = 0
    var createCommandCalled: Bool {
        return createCommandCallsCount > 0
    }
    var createCommandReceivedCommand: CommandBlock<Data>?
    var createCommandReceivedInvocations: [CommandBlock<Data>] = []
    var createCommandReturnValue: (any PingxSocket)!
    var createCommandClosure: ((CommandBlock<Data>) throws -> any PingxSocket)?

    func create(command: CommandBlock<Data>) throws -> any PingxSocket {
        if let error = createCommandThrowableError {
            throw error
        }
        createCommandCallsCount += 1
        createCommandReceivedCommand = command
        createCommandReceivedInvocations.append(command)
        return try createCommandClosure.map({ try $0(command) }) ?? createCommandReturnValue
    }

}
