import XCTest
@testable import pingx

// MARK: - ResponseReceiver

final class ResponseReceiver {
    var receivedResponse: [Response] = []
    var receivedErrors: [PingerError] = []
    var expectation: XCTestExpectation?
}

extension ResponseReceiver: PingerDelegate {
    func pinger(_ pinger: Pinger, request: Request, didReceive response: Response) {
        receivedResponse.append(response)
        expectation?.fulfill()
    }
    
    func pinger(_ pinger: Pinger, request: Request, didCompleteWithError error: PingerError) {
        receivedErrors.append(error)
        expectation?.fulfill()
    }
}
