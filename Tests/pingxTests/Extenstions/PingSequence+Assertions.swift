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

import Foundation

@testable import pingx

/// Collects values from the given sequence.
/// - Parameters:
///   - sequence: Observable sequence
///   - count: Number of values  to collect
///   - timeout: Time limit for collecting values (in milliseconds)
/// - Returns: An array of collected elements
@discardableResult func collectValuesFromPingSequence(
    sequence: PingSequence,
    count: Int = .max,
    timeout: Interval = .milliseconds(50)
) async throws -> [PingResult] {
    try await withThrowingTaskGroup(
        of: [PingResult].self,
        returning: [PingResult].self
    ) { taskGroup in
        taskGroup.addTask {
            var values: [PingResult] = []

            for try await value in sequence where values.count < count {
                values.append(value)
            }
            
            return values
        }
        
        taskGroup.addTask {
            try await Task.sleep(nanoseconds: UInt64(timeout.nanoseconds))
            return []
        }
        
        defer { taskGroup.cancelAll() }

        return try await taskGroup.next().unsafelyUnwrapped
    }
}

func observerPingSequenceWithoutReturningResult(
    sequence: PingSequence,
    timeout: Interval = .milliseconds(50)
) async throws {
    try await collectValuesFromPingSequence(
        sequence: sequence,
        timeout: timeout
    )
}
