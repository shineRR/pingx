import XCTest
@testable import pingx

// MARK: - XCTestCase

extension XCTestCase {
    func expectFatalError(expectedMessage: String, testcase: @escaping () -> Void) {
        let expectation = expectation(description: "expectingFatalError")
        var assertionMessage = String()

        FatalError.trigger = { (message, _, _) in
            assertionMessage = message()
            DispatchQueue.main.async {
                expectation.fulfill()
            }
            Thread.exit()
            Swift.fatalError("Never be executed")
        }

        Thread(block: testcase).start()

        waitForExpectations(timeout: 0.1) { _ in
            XCTAssertEqual(expectedMessage, assertionMessage)
            FatalError.trigger = Swift.fatalError
        }
    }
}
