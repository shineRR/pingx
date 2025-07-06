//
// The MIT License (MIT)
//
// Copyright © 2025 Ilya Baryka. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Testing
import XCTest

func expectTo(
    expression: @escaping () -> Bool,
    timeout: TimeInterval = 1.0,
    description: String = "",
    sourceLocation: SourceLocation = #_sourceLocation
) async {
    let expectation = XCTestExpectation(description: description)
    
    let task = Task {
        while !expression() {
            try await Task.sleep(nanoseconds: 20_000_000) // 20ms
        }

        expectation.fulfill()
    }
    
    let result = await XCTWaiter.fulfillment(of: [expectation], timeout: timeout)
    task.cancel()

    #expect(
        result == .completed,
        .__block(description),
        sourceLocation: sourceLocation
    )
}

func expectNotTo(
    expression: @escaping () -> Bool,
    timeout: TimeInterval = 1.0,
    description: String = "",
    sourceLocation: SourceLocation = #_sourceLocation
) async {
    let expectation = XCTestExpectation(description: description)
    expectation.isInverted = true

    let task = Task {
        while !expression() {
            try await Task.sleep(nanoseconds: 20_000_000) // 20ms
        }

        expectation.fulfill()
    }
    
    let result = await XCTWaiter.fulfillment(of: [expectation], timeout: timeout)
    task.cancel()

    #expect(
        result == .completed,
        .__block(description),
        sourceLocation: sourceLocation
    )
}

func expectToEventuallyBeCalled(
    actualCallsCount: @autoclosure @escaping () -> Int,
    expectedCallsCount: Int = 1,
    timeout: TimeInterval = 1.0,
    sourceLocation: SourceLocation = #_sourceLocation
) async {
    await expectTo(
        expression: { actualCallsCount() == expectedCallsCount },
        timeout: timeout,
        description: "Wait for actualCallsCount to reach \(expectedCallsCount), got: \((actualCallsCount()))",
        sourceLocation: sourceLocation
    )
}

func expectNotToEventuallyBeCalled(
    actualCallsCount: @autoclosure @escaping () -> Int,
    expectedCallsCount: Int = 1,
    timeout: TimeInterval = 0.1,
    sourceLocation: SourceLocation = #_sourceLocation
) async {
    await expectNotTo(
        expression: { actualCallsCount() >= expectedCallsCount },
        timeout: timeout,
        description: "Wait for actualCallsCount to not reach \(expectedCallsCount), got: \((actualCallsCount()))",
        sourceLocation: sourceLocation
    )
}

func expectNotToEventuallyBeNil<T>(
    actualValue: @autoclosure @escaping () -> T?,
    timeout: TimeInterval = 1.0,
    sourceLocation: SourceLocation = #_sourceLocation
) async {
    await expectTo(
        expression: { actualValue() != nil },
        timeout: timeout,
        description: "Wait for actualCallsCount not to be nil",
        sourceLocation: sourceLocation
    )
}
