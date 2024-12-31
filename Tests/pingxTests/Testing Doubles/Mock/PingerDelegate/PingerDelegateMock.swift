import XCTest
@testable import pingx

// MARK: - PingerDelegateMock

final class PingerDelegateMock: PingerDelegate {
    typealias ResponseInvocation = (pinger: Pinger, request: Request, response: Response)
    typealias ErrorInvocation = (pinger: Pinger, request: Request, error: PingerError)

    private(set) var pingerDidReceiveResponseCalledCount: Int = 0
    private(set) var pingerDidReceiveResponseInvocations: [ResponseInvocation] = []
    private(set) var pingerDidCompleteWithErrorCalledCount: Int = 0
    private(set) var pingerDidCompleteWithErrorInvocations: [ErrorInvocation] = []

    func pinger(_ pinger: Pinger, request: Request, didReceive response: Response) {
        pingerDidReceiveResponseCalledCount += 1
        pingerDidReceiveResponseInvocations.append((pinger, request, response))
    }

    func pinger(_ pinger: Pinger, request: Request, didCompleteWithError error: PingerError) {
        pingerDidCompleteWithErrorCalledCount += 1
        pingerDidCompleteWithErrorInvocations.append((pinger, request, error))
    }
}