// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import pingx

final class ICMPHeaderFactoryMock: ICMPHeaderFactoryProtocol {

    // MARK: - make

    var makeThrowableError: (any Error)?
    var makeCallsCount = 0
    var makeCalled: Bool {
        return makeCallsCount > 0
    }
    var makeReceivedArguments: (type: ICMPType, identifier: UInt16)?
    var makeReceivedInvocations: [(type: ICMPType, identifier: UInt16)] = []
    var makeReturnValue: ICMPHeader!
    var makeClosure: ((ICMPType, UInt16) throws -> ICMPHeader)?

    func make(type: ICMPType, identifier: UInt16) throws -> ICMPHeader {
        makeCallsCount += 1
        makeReceivedArguments = (type: type, identifier: identifier)
        makeReceivedInvocations.append((type: type, identifier: identifier))
        if let error = makeThrowableError {
            throw error
        }
        if let makeClosure = makeClosure {
            return try makeClosure(type, identifier)
        } else {
            return makeReturnValue
        }
    }

}

// swiftlint:enable all
