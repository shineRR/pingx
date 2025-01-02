// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import pingx

class PacketFactoryMock: PacketFactory {

    // MARK: - create

    var createThrowableError: (any Error)?
    var createCallsCount = 0
    var createCalled: Bool {
        return createCallsCount > 0
    }
    var createReceivedArguments: (identifier: UInt16, type: PacketType)?
    var createReceivedInvocations: [(identifier: UInt16, type: PacketType)] = []
    var createReturnValue: Packet!
    var createClosure: ((UInt16, PacketType) throws -> Packet)?

    func create(identifier: UInt16, type: PacketType) throws -> Packet {
        createCallsCount += 1
        createReceivedArguments = (identifier: identifier, type: type)
        createReceivedInvocations.append((identifier: identifier, type: type))
        if let error = createThrowableError {
            throw error
        }
        if let createClosure = createClosure {
            return try createClosure(identifier, type)
        } else {
            return createReturnValue
        }
    }

}

// swiftlint:enable all
