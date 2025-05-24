// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

@testable import pingx

final class AsyncPingerMock: AsyncPingerProtocol {

    // MARK: - ping

    var pingCallsCount = 0
    var pingCalled: Bool {
        return pingCallsCount > 0
    }
    var pingReceivedRequest: (Request)?
    var pingReceivedInvocations: [(Request)] = []
    var pingReturnValue: PingSequence!
    var pingClosure: ((Request) -> PingSequence)?

    func ping(request: Request) -> PingSequence {
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

    var cancelCallsCount = 0
    var cancelCalled: Bool {
        return cancelCallsCount > 0
    }
    var cancelReceivedRequest: (Request)?
    var cancelReceivedInvocations: [(Request)] = []
    var cancelClosure: ((Request) -> Void)?

    func cancel(request: Request) {
        cancelCallsCount += 1
        cancelReceivedRequest = request
        cancelReceivedInvocations.append(request)
        cancelClosure?(request)
    }

}

// swiftlint:enable all
