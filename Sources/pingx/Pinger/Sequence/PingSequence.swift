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

struct PingSequence: AsyncSequence, AsyncIteratorProtocol {
    typealias Failure = Never

    private let request: Request
    private let pinger: AsyncPinger
    
    init(request: Request, pinger: AsyncPinger) {
        self.request = request
        self.pinger = pinger
    }

    mutating func next() async throws -> PingerResult? {
        guard request.demand != .none else { return nil }
        
        try Task.checkCancellation()
        request.decreaseDemand()
        
        let result = await withTaskGroup(
            of: PingerResult.self,
            returning: Optional<PingerResult>.self
        ) { [weak pinger, request] taskGroup in
            taskGroup.addTask {
                do {
                    try await Task.sleep(nanoseconds: UInt64(request.timeoutInterval * 1_000_000))
                } catch {}
                
                return .failure(.timeout)
            }
            
            taskGroup.addTask {
                return await withCheckedContinuation { continutaion in
                    pinger?.ping(request) { result in
                        continutaion.resume(returning: result)
                    }
                }
            }
            
            defer {
                taskGroup.cancelAll()
                pinger?.cancel(request: request)
            }
            
            return await taskGroup.next()
        }

        return result
    }
    
    func makeAsyncIterator() -> PingSequence { self }
}
