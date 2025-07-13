// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import pingx

final class AsyncPingerMock: AsyncPingerProtocol {

    // MARK: - ping

    public var pingCallsCount = 0
    public var pingCalled: Bool {
        return pingCallsCount > 0
    }
    public var pingReceivedRequest: (Request)?
    public var pingReceivedInvocations: [(Request)] = []
    public var pingReturnValue: AnyPingSequence!
    public var pingClosure: ((Request) -> AnyPingSequence)?

    public func ping(request: Request) -> AnyPingSequence {
        pingCallsCount += 1
        pingReceivedRequest = request
        pingReceivedInvocations.append(request)
        if let pingClosure = pingClosure {
            return pingClosure(request)
        } else {
            return pingReturnValue
        }
    }

    // MARK: - cancel

    public var cancelCallsCount = 0
    public var cancelCalled: Bool {
        return cancelCallsCount > 0
    }
    public var cancelReceivedRequestId: (Request.Identifier)?
    public var cancelReceivedInvocations: [(Request.Identifier)] = []
    public var cancelClosure: ((Request.Identifier) -> Void)?

    public func cancel(requestId: Request.Identifier) {
        cancelCallsCount += 1
        cancelReceivedRequestId = requestId
        cancelReceivedInvocations.append(requestId)
        cancelClosure?(requestId)
    }

}

// swiftlint:enable all
