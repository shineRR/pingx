import XCTest

extension XCTestCase {
    func XCTAssertEventuallyEqual<T: Equatable>(
        _ expression1: @autoclosure @escaping () -> T,
        _ expression2: T,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let expectation = XCTestExpectation(description: "Eventually equal")
        
        let startTime = Date()
        let timeoutDate = startTime.addingTimeInterval(timeout)
        
        DispatchQueue.global().async {
            while Date() < timeoutDate {
                if expression1() == expression2 {
                    expectation.fulfill()
                    break
                }
                usleep(100_000)
            }
        }
        
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        
        if result != .completed {
            XCTFail("Expected \(expression1()) to eventually equal \(expression2)", file: file, line: line)
        }
    }
}
