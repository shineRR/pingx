// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import pingx

final class ICMPPacketExtractorMock: ICMPPacketExtractorProtocol {

    // MARK: - extract

    var extractThrowableError: (any Error)?
    var extractCallsCount = 0
    var extractCalled: Bool {
        return extractCallsCount > 0
    }
    var extractReceivedData: (Data)?
    var extractReceivedInvocations: [(Data)] = []
    var extractReturnValue: ICMPPacket!
    var extractClosure: ((Data) throws -> ICMPPacket)?

    func extract(from data: Data) throws -> ICMPPacket {
        extractCallsCount += 1
        extractReceivedData = data
        extractReceivedInvocations.append(data)
        if let error = extractThrowableError {
            throw error
        }
        if let extractClosure = extractClosure {
            return try extractClosure(data)
        } else {
            return extractReturnValue
        }
    }

}

// swiftlint:enable all
