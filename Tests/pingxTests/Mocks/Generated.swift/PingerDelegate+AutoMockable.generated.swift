// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import pingx

class PingerDelegateMock: PingerDelegate {

    //MARK: - pinger

    var pingerRequestDidReceiveCallsCount = 0
    var pingerRequestDidReceiveCalled: Bool {
        return pingerRequestDidReceiveCallsCount > 0
    }
    var pingerRequestDidReceiveReceivedArguments: (pinger: Pinger, request: Request, response: Response)?
    var pingerRequestDidReceiveReceivedInvocations: [(pinger: Pinger, request: Request, response: Response)] = []
    var pingerRequestDidReceiveClosure: ((Pinger, Request, Response) -> Void)?

    func pinger(_ pinger: Pinger, request: Request, didReceive response: Response) {
        pingerRequestDidReceiveCallsCount += 1
        pingerRequestDidReceiveReceivedArguments = (pinger: pinger, request: request, response: response)
        pingerRequestDidReceiveReceivedInvocations.append((pinger: pinger, request: request, response: response))
        pingerRequestDidReceiveClosure?(pinger, request, response)
    }

    //MARK: - pinger

    var pingerRequestDidCompleteWithErrorCallsCount = 0
    var pingerRequestDidCompleteWithErrorCalled: Bool {
        return pingerRequestDidCompleteWithErrorCallsCount > 0
    }
    var pingerRequestDidCompleteWithErrorReceivedArguments: (pinger: Pinger, request: Request, error: PingerError)?
    var pingerRequestDidCompleteWithErrorReceivedInvocations: [(pinger: Pinger, request: Request, error: PingerError)] = []
    var pingerRequestDidCompleteWithErrorClosure: ((Pinger, Request, PingerError) -> Void)?

    func pinger(_ pinger: Pinger, request: Request, didCompleteWithError error: PingerError) {
        pingerRequestDidCompleteWithErrorCallsCount += 1
        pingerRequestDidCompleteWithErrorReceivedArguments = (pinger: pinger, request: request, error: error)
        pingerRequestDidCompleteWithErrorReceivedInvocations.append((pinger: pinger, request: request, error: error))
        pingerRequestDidCompleteWithErrorClosure?(pinger, request, error)
    }

}
