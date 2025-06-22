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

public struct PingSequence: AsyncSequence, AsyncIteratorProtocol {
    private var request: Request
    private let pinger: AsyncPinger
    
    init(request: Request, pinger: AsyncPinger) {
        self.request = request
        self.pinger = pinger
    }

    public mutating func next() async throws -> PingResult? {
        guard request.demand != .none else { return nil }
        
        try Task.checkCancellation()
        
        let result = await withTaskGroup(
            of: AsyncPingerResult.self,
            returning: Optional<AsyncPingerResult>.self
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
                pinger?.cancel(requestId: request.id)
            }
            
            return await taskGroup.next()
        }
        
        request.decreaseDemand()
        request.incrementSequenceNumber()
        
        if case .cancelled = result?.error {
            request.setDemand(.none)
        }
        
        return result?
            .map { icmpPacket in
                Response(
                    destination: icmpPacket.ipHeader.sourceAddress,
                    duration: (CFAbsoluteTimeGetCurrent() - icmpPacket.icmpHeader.payload.timestamp) * 1000,
                    sequenceNumber: icmpPacket.icmpHeader.sequenceNumber
                )
            }
            .mapError { $0.mapToPingError() }
    }
    
    public func makeAsyncIterator() -> PingSequence { self }
}

private extension AsyncPingerError {
    func mapToPingError() -> PingError {
        switch self {
        case .cancelled:
            return .cancelled
        case .timeout:
            return .timeout
        case .socketCreationError:
            return .socketFailed
        case .responseStructureInconsistent:
            return .responseStructureInconsistent
        case .unableToCreatePacket, .unknown:
            return .internalError(self)
        }
    }
}
