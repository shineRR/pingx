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

@testable import pingx

@Suite
struct PingerTests {
    private let pingSequence: MockPingSequence
    private let asyncPinger: AsyncPingerMock
    private var pinger: Pinger!
    
    init() {
        self.pingSequence = MockPingSequence()

        self.asyncPinger = AsyncPingerMock()
        self.asyncPinger.pingReturnValue = AnyPingSequence(
            sequence: pingSequence
        )
        
        self.pinger = Pinger(
            asyncPinger: asyncPinger
        )
    }
    
    
    @Test("When ping is called, starts pinging using the async pinger")
    func ping_callsASyncPinger() async {
        pinger.ping()
        
        await expectToEventuallyBeCalled(
            actualCallsCount: asyncPinger.pingCallsCount,
            expectedCallsCount: 1
        )
    }
    
    @Test("When the sequence emits events, calls completion with received events")
    func ping_whenSequenceEmitsEvent_callsCompletionWithReceivedEvent() async {
        let completion = MockFunc<PingResult, Void>()
        let pingResults: [PingResult] = [
            .success(.sample()),
            .failure(.timeout),
            .success(.sample())
        ]

        pinger.ping(completion: completion)
        for pingResult in pingResults {
            await pingSequence.send(pingResult)
        }
        
        await expectToEventuallyBeCalled(
            actualCallsCount: completion.count,
            expectedCallsCount: 3
        )
        #expect(completion.parameters.elementsEqual(pingResults, by: { $0.equals($1) }))
    }
    
    @Test("When sequence completes, cancels request by id")
    func ping_whenSequenceCompletes_cancelsRequestById() async {
        let request = Request.sample()

        pinger.ping(request: request)
        await pingSequence.finish()

        await expectToEventuallyBeCalled(
            actualCallsCount: asyncPinger.cancelCallsCount,
            expectedCallsCount: 1
        )
        #expect(asyncPinger.cancelReceivedInvocations == [request.identifier])
    }
    
    @Test("When request is cancelled, cancels request by id")
    func cancel_cancelsRequestById() async {
        let request = Request.sample()
        
        pinger.cancel(requestId: request.identifier)
        
        #expect(asyncPinger.cancelReceivedInvocations == [request.identifier])
    }
    
    @Test("When pinger is deinitialized, cancels all active requests")
    mutating func cancel_cancelsAllActiveRequests() async {
        let request1 = Request.sample(id: .sample(id: 0))
        let request2 = Request.sample(id: .sample(id: 1))
        
        pinger.ping(request: request1)
        pinger.ping(request: request2)
        pinger = nil
        
        #expect(
            asyncPinger.cancelReceivedInvocations.sorted(by: { $0.id < $1.id }) == [
                request1.identifier, request2.identifier
            ]
        )
    }
}

private extension Pinger {
    func ping(
        request: Request = .sample(),
        completion: MockFunc<PingResult, Void> = MockFunc()
    ) {
        ping(
            request: request,
            completion: completion.call
        )
    }
}
