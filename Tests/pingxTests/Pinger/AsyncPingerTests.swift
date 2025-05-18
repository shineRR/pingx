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
import Testing
import XCTest

@testable import pingx

@Suite
struct AsyncPingerTests {
    private let socket: PingxSocketMock
    private let icmpHeaderFactory: ICMPHeaderFactoryMock
    private let icmpPacketExtractor: ICMPPacketExtractorMock
    private let socketFactory: SocketFactoryMock
    private let pinger: AsyncPinger
    
    init() {
        self.socket = PingxSocketMock()
        self.socket.sendReturnValue = .success

        self.icmpHeaderFactory = ICMPHeaderFactoryMock()
        self.icmpHeaderFactory.makeReturnValue = ICMPHeader.sample()
        
        self.icmpPacketExtractor = ICMPPacketExtractorMock()
        self.icmpPacketExtractor.extractReturnValue = ICMPPacket.sample()

        self.socketFactory = SocketFactoryMock()
        self.socketFactory.makeReturnValue = socket

        self.pinger = AsyncPinger(
            icmpHeaderFactory: icmpHeaderFactory,
            icmpPacketExtractor: icmpPacketExtractor,
            socketFactory: socketFactory
        )
    }
    
    @Test("When socket is not created, it creates socket")
    func send_whenSocketIsNotCreated_createsSocket() async throws {
        let request = Request.sample()

        let sequence = pinger.ping(request: request)
        try await observerPingSequenceWithoutReturningResult(sequence: sequence)
        
        #expect(socketFactory.makeCallsCount == 1)
    }
    
    @Test("When socket is created, it doesn't create socket again")
    func send_whenSocketIsCreated_doesNotCreateSocket() async throws {
        let request = Request.sample()

        let sequence1 = pinger.ping(request: request)
        try await observerPingSequenceWithoutReturningResult(sequence: sequence1)
        
        let sequence2 = pinger.ping(request: request)
        try await observerPingSequenceWithoutReturningResult(sequence: sequence2)
        
        #expect(socketFactory.makeCallsCount == 1)
    }
    
    @Test("When socket creation failed, it emits pingerError.socketCreationError")
    func send_whenSocketIsNotCreatedAndCreationFailed_emitsSocketCreationError() async throws {
        let request = Request.sample()
        socketFactory.makeThrowableError = AnyError()

        let sequence = pinger.ping(request: request)

        try await checkThat(
            sequence: sequence,
            emits: [.failure(.socketCreationError)]
        )
    }
    
    @Test("When packet creation failed, it emits pingerError.unableToCreatePacket")
    func send_whenPacketCreationFailed_emitsPacketCreationError() async throws {
        let request = Request.sample()
        socketFactory.makeReturnValue = PingxSocketMock()
        icmpHeaderFactory.makeThrowableError = AnyError()

        let sequence = pinger.ping(request: request)
        
        try await checkThat(
            sequence: sequence,
            emits: [.failure(.unableToCreatePacket)]
        )
    }
    
    @Test("When setup is completed, sends a packet using the created socket")
    func send_whenSetUpIsCompleted_sendsPacket() async throws {
        let request = Request.sample()
        let icmpHeader = ICMPHeader.sample()
        icmpHeaderFactory.makeReturnValue = icmpHeader

        let sequence = pinger.ping(request: request)
        try await observerPingSequenceWithoutReturningResult(sequence: sequence)

        #expect(socket.sendCallsCount == 1)
        #expect(socket.sendReceivedArguments?.address == request.destination.socketAddress as CFData)
        #expect(socket.sendReceivedArguments?.data == icmpHeader.data as CFData)
        #expect(socket.sendReceivedArguments?.timeout == request.timeoutInterval)
    }
    
    @Test("When request failed, it emits pingerError.unknown")
    func send_whenPacketSendingFailed_emitsError() async throws {
        let request = Request.sample()
        socket.sendReturnValue = .error

        let sequence = pinger.ping(request: request)
        
        try await checkThat(
            sequence: sequence,
            emits: [.failure(.unknown)]
        )
    }
    
    @Test("When packet sending timed out, it emits pingerError.timeout")
    func send_whenPacketSendingTimedOut_emitsTimedOutError() async throws {
        let request = Request.sample()
        socket.sendReturnValue = .timeout

        let sequence = pinger.ping(request: request)
        
        try await checkThat(
            sequence: sequence,
            emits: [.failure(.timeout)]
        )
    }
    
    @Test("When response parsing is successful, it emits icmp packet")
    func send_whenResponseParsingSucceeded_emitsIcmpPacket() async throws {
        let request = Request.sample()
        let icmpPacket = ICMPPacket.sample(
            icmpHeader: .sample(
                identifier: request.id
            )
        )
        icmpPacketExtractor.extractReturnValue = icmpPacket

        let sequence = pinger.ping(request: request)
        
        try await checkThat(
            sequence: sequence,
            emits: [.success(icmpPacket)],
            after: {
                await expectToEventuallyBeCalled(actualCallsCount: socket.sendCallsCount)
                socketFactory.makeReceivedCommand?.closure(Data())
            }
        )
    }
    
    @Test("When response parsing is successful but identifier is different, it doesn't emit icmp packet")
    func send_whenResponseParsingSucceededButIdentifierIsDifferent_doesNotEmitIcmpPacket() async throws {
        let request = Request.sample(id: 1)
        let icmpPacket = ICMPPacket.sample(
            icmpHeader: .sample(identifier: 2)
        )
        icmpPacketExtractor.extractReturnValue = icmpPacket

        let sequence = pinger.ping(request: request)
        
        try await checkThat(
            sequence: sequence,
            emits: [],
            after: {
                await expectToEventuallyBeCalled(actualCallsCount: socket.sendCallsCount)
                socketFactory.makeReceivedCommand?.closure(Data())
            }
        )
    }

    @Test("When response parsing is failed and icmp header is missing, it doesn't emit")
    func send_whenResponseParsingFailedAndIcmpHeaderIsMissing_doesNotEmit() async throws {
        let request = Request.sample()
        let error = ICMPResponseValidationError.missedIcmpHeader
        icmpPacketExtractor.extractThrowableError = error

        let sequence = pinger.ping(request: request)
        
        try await checkThat(
            sequence: sequence,
            emits: [],
            after: {
                await expectToEventuallyBeCalled(actualCallsCount: socket.sendCallsCount)
                socketFactory.makeReceivedCommand?.closure(Data())
            }
        )
    }

    @Test("When response parsing is failed and icmp header is present, it emits validation error")
    func send_whenResponseParsingFailedButIcmpHeaderIsPresent_emitsValidationError() async throws {
        let request = Request.sample()
        let icmpHeader = ICMPHeader.sample(identifier: request.id)
        let error = ICMPResponseValidationError.invalidCode(icmpHeader)
        icmpPacketExtractor.extractThrowableError = error

        let sequence = pinger.ping(request: request)
        
        try await checkThat(
            sequence: sequence,
            emits: [.failure(.validationError(error))],
            after: {
                await expectToEventuallyBeCalled(actualCallsCount: socket.sendCallsCount)
                socketFactory.makeReceivedCommand?.closure(Data())
            }
        )
    }
    
    @Test("When response parsing is failed with unknown response, it doesn't emit")
    func send_whenResponseParsingFailedWithUnknownError_doesNotEmit() async throws {
        let request = Request.sample()
        icmpPacketExtractor.extractThrowableError = AnyError()

        let sequence = pinger.ping(request: request)
        
        try await checkThat(
            sequence: sequence,
            emits: [],
            after: {
                await expectToEventuallyBeCalled(actualCallsCount: socket.sendCallsCount)
                socketFactory.makeReceivedCommand?.closure(Data())
            }
        )
    }
    
    @Test("When request timed out, it emits pingerError.timeout")
    func send_whenRequestIsTimedOut_emitsTimedOutError() async throws {
        let request = Request.sample(timeoutInterval: 1)

        let sequence = pinger.ping(request: request)
        
        try await checkThat(
            sequence: sequence,
            emits: [.failure(.timeout)]
        )
    }
    
    @Test("When request demand is zero, doesn't emit values")
    func send_whenRequestDemandIsZero_doesNotEmitValues() async throws {
        let request = Request.sample(demand: .none)

        let sequence = pinger.ping(request: request)
        
        try await checkThat(
            sequence: sequence,
            emits: []
        )
    }
    
    @Test(
        "When request demand is greater than one, the corresponding number of values is emitted",
        arguments: [1, 2, 3, 4, 5]
    )
    func send_whenRequestDemandIsGreaterThanOne_emitsCorrespondingNumberOfValues(demand: Int) async throws {
        let request = Request.sample(demand: .max(demand))
        let icmpPacket = ICMPPacket.sample(
            icmpHeader: .sample(
                identifier: request.id
            )
        )
        icmpPacketExtractor.extractReturnValue = icmpPacket

        let sequence = pinger.ping(request: request)
        
        try await checkThat(
            sequence: sequence,
            emits: Array(repeating: .success(icmpPacket), count: demand),
            after: {
                for callsCount in 1...demand {
                    await expectToEventuallyBeCalled(
                        actualCallsCount: socket.sendCallsCount,
                        expectedCallsCount: callsCount
                    )
                    socketFactory.makeReceivedCommand?.closure(Data())
                }
            },
            timeout: 1000
        )
    }
}

private extension AsyncPingerTests {
    func checkThat(
        sequence: PingSequence,
        emits expectedValues: [PingerResult],
        after operation: (() async -> Void)? = nil,
        timeout: TimeInterval = 50,
        sourceLocation: SourceLocation = #_sourceLocation
    ) async throws {
        let expectation = XCTestExpectation(
            description: "Wait for expectedValues to be equal to the values emitted by the sequence"
        )
        
        Task {
            let values = try await collectValuesFromPingSequence(sequence: sequence, timeout: timeout)
            #expect(expectedValues == values, sourceLocation: sourceLocation)

            expectation.fulfill()
        }
        
        await operation?()
        
        let result = await XCTWaiter.fulfillment(
            of: [expectation],
            timeout: timeout * 1000
        )
        #expect(result == .completed)
    }
}
