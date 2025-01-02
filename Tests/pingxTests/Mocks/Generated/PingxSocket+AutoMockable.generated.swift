// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import pingx

class PingxSocketMock: PingxSocket {

    // MARK: - send

    var sendCallsCount = 0
    var sendCalled: Bool {
        return sendCallsCount > 0
    }
    var sendReceivedArguments: (address: CFData, data: CFData, timeout: CFTimeInterval)?
    var sendReceivedInvocations: [(address: CFData, data: CFData, timeout: CFTimeInterval)] = []
    var sendReturnValue: CFSocketError!
    var sendClosure: ((CFData, CFData, CFTimeInterval) -> CFSocketError)?

    func send(address: CFData, data: CFData, timeout: CFTimeInterval) -> CFSocketError {
        sendCallsCount += 1
        sendReceivedArguments = (address: address, data: data, timeout: timeout)
        sendReceivedInvocations.append((address: address, data: data, timeout: timeout))
        if let sendClosure = sendClosure {
            return sendClosure(address, data, timeout)
        } else {
            return sendReturnValue
        }
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
