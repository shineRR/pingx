// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import pingx

class PacketSenderMock: PacketSender {
    weak var delegate: PacketSenderDelegate?

    // MARK: - send

    var sendCallsCount = 0
    var sendCalled: Bool {
        return sendCallsCount > 0
    }
    var sendReceivedRequest: (Request)?
    var sendReceivedInvocations: [(Request)] = []
    var sendClosure: ((Request) -> Void)?

    func send(_ request: Request) {
        sendCallsCount += 1
        sendReceivedRequest = request
        sendReceivedInvocations.append(request)
        sendClosure?(request)
    }

    // MARK: - invalidate

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

// swiftlint:enable all
