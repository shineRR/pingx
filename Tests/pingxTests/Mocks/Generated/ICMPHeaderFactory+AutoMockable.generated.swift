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
    var makeReceivedRequest: (Request)?
    var makeReceivedInvocations: [(Request)] = []
    var makeReturnValue: ICMPHeader!
    var makeClosure: ((Request) throws -> ICMPHeader)?

    func make(from request: Request) throws -> ICMPHeader {
        makeCallsCount += 1
        makeReceivedRequest = request
        makeReceivedInvocations.append(request)
        if let error = makeThrowableError {
            throw error
        }
        if let makeClosure = makeClosure {
            return try makeClosure(request)
        } else {
            return makeReturnValue
        }
    }

}

// swiftlint:enable all
