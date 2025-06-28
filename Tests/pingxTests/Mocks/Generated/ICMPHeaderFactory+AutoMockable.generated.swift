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
    var makeReceivedArguments: (type: ICMPType, requestIdentifier: Request.Identifier, sequenceNumber: UInt16)?
    var makeReceivedInvocations: [(type: ICMPType, requestIdentifier: Request.Identifier, sequenceNumber: UInt16)] = []
    var makeReturnValue: ICMPHeader!
    var makeClosure: ((ICMPType, Request.Identifier, UInt16) throws -> ICMPHeader)?

    func make(type: ICMPType, requestIdentifier: Request.Identifier, sequenceNumber: UInt16) throws -> ICMPHeader {
        makeCallsCount += 1
        makeReceivedArguments = (type: type, requestIdentifier: requestIdentifier, sequenceNumber: sequenceNumber)
        makeReceivedInvocations.append((type: type, requestIdentifier: requestIdentifier, sequenceNumber: sequenceNumber))
        if let error = makeThrowableError {
            throw error
        }
        if let makeClosure = makeClosure {
            return try makeClosure(type, requestIdentifier, sequenceNumber)
        } else {
            return makeReturnValue
        }
    }

}

// swiftlint:enable all
