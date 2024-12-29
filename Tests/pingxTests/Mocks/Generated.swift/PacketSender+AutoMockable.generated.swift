// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import pingx

class PacketSenderMock: PacketSender {
    var delegate: PacketSenderDelegate?

    //MARK: - send

    var sendThrowableError: Error?
    var sendCallsCount = 0
    var sendCalled: Bool {
        return sendCallsCount > 0
    }
    var sendReceivedRequest: Request?
    var sendReceivedInvocations: [Request] = []
    var sendClosure: ((Request) throws -> Void)?

    func send(_ request: Request) throws {
        if let error = sendThrowableError {
            throw error
        }
        sendCallsCount += 1
        sendReceivedRequest = request
        sendReceivedInvocations.append(request)
        try sendClosure?(request)
    }

    //MARK: - invalidate

    var invalidateCallsCount = 0
    var invalidateCalled: Bool {
        return invalidateCallsCount > 0
    }
    var invalidateClosure: (() -> Void)?

    func invalidate() {
        invalidateCallsCount += 1
        invalidateClosure?()
    }

}
