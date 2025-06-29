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
struct ICMPPackageExtractorTests {
    private let extractor: ICMPPacketExtractor

    init () {
        self.extractor = ICMPPacketExtractor()
    }

    @Test("When data is valid, it returns icmp packet")
    func extract_whenDataIsValid_returnsIcmpPacket() throws {
        let request = Request.sample()
        let data = try makeCorrectData(for: request)

        let icmpPacket = try extractor.extract(from: data)

        #expect(icmpPacket.icmpHeader.identifier == request.identifier.id)
        #expect(icmpPacket.ipHeader.sourceAddress == request.destination)
    }

    @Test("When icmp type is not echo reply, it throws invalidType error")
    func extract_whenIcmpTypeIsNotEchoReply_throwsInvalidTypeError() async throws {
        let icmpHeader = ICMPHeader.sample(type: .addressMaskReply)
        let data = makeErrorData(icmpHeader: icmpHeader)

        #expect(throws: ICMPResponseValidationError.invalidType(icmpHeader)) {
            try extractor.extract(from: data)
        }
    }

    @Test("When code is not zero, it throws invalidType error")
    func extract_whenCodeIsNotZero_throwsInvalidCodeError() async throws {
        let icmpHeader = ICMPHeader.sample(code: .max)
        let data = makeErrorData(icmpHeader: icmpHeader)

        #expect(throws: ICMPResponseValidationError.invalidCode(icmpHeader)) {
            try extractor.extract(from: data)
        }
    }

    @Test("When checksum is wrong, it throws checksumMismatch error")
    func extract_whenChecksumIsWrong_throwsChecksumMismatchError() async throws {
        let icmpHeader = ICMPHeader.sample(checksum: .zero)
        let data = makeErrorData(icmpHeader: icmpHeader)

        #expect(throws: ICMPResponseValidationError.checksumMismatch(icmpHeader)) {
            try extractor.extract(from: data)
        }
    }

    @Test("When ip header is missing, it throws missedIpHeader error")
    func extract_whenIpHeaderIsMissing_throwsMissedIpHeaderError() async throws {
        let data = makeErrorData(shouldAddIpHeader: false)

        #expect(throws: ICMPResponseValidationError.missedIpHeader) {
            try extractor.extract(from: data)
        }
    }

    @Test("When icmp header is missing, it throws missedIcmpHeader error")
    func extract_whenIcmpHeaderIsMissing_throwsMissedIcmpHeaderError() async throws {
        let data = makeErrorData(icmpHeader: nil)

        #expect(throws: ICMPResponseValidationError.missedIcmpHeader) {
            try extractor.extract(from: data)
        }
    }
}

private extension ICMPPackageExtractorTests {
    func makeCorrectData(
        for request: Request
    ) throws -> Data {
        let ipHeader = IPHeader.sample(
            totalLength: .zero,
            headerChecksum: .zero,
            sourceAddress: request.destination,
            destinationAddress: .init(address: (127, 0, 0, 1))
        )
        var icmpHeader = ICMPHeader.sample(
            type: .echoReply,
            code: .zero,
            identifier: request.identifier.id,
            sequenceNumber: .zero,
            payload: .sample(
                identifier: .sample(
                    id: request.identifier.id,
                    uniqueToken: request.identifier.uniqueToken
                )
            )
        )

        guard let checksum = try? ICMPChecksum()(icmpHeader: icmpHeader) else {
            throw NSError(domain: "Checksum calculation failed", code: .zero)
        }
        icmpHeader.setChecksum(checksum)

        var icmpPacket = ICMPPacket(ipHeader: ipHeader, icmpHeader: icmpHeader)
        let data = withUnsafeBytes(of: &icmpPacket) { Data($0) }

        return data
    }

    func makeErrorData(
        for request: Request = .sample(),
        icmpHeader: ICMPHeader? = nil,
        shouldAddIpHeader: Bool = true
    ) -> Data {
        let ipHeader = IPHeader.sample(
            totalLength: .zero,
            headerChecksum: .min,
            sourceAddress: request.destination,
            destinationAddress: request.destination
        )
        let data: Data

        if let icmpHeader {
            var icmp = ICMPPacket.sample(ipHeader: ipHeader, icmpHeader: icmpHeader)
            data = withUnsafeBytes(of: &icmp) { Data($0) }
        } else if shouldAddIpHeader {
            var ipHeader = ipHeader
            data = Data(bytes: &ipHeader, count: MemoryLayout<IPHeader>.size)
        } else {
            data = Data()
        }

        return data
    }
}

extension ICMPResponseValidationError: Equatable {
    public static func == (lhs: ICMPResponseValidationError, rhs: ICMPResponseValidationError) -> Bool {
        switch (lhs, rhs) {
        case (.checksumMismatch(let lValue), .checksumMismatch(let rValue)):
            return lValue == rValue
        case (.invalidType(let lValue), .invalidType(let rValue)):
            return lValue == rValue
        case (.invalidCode(let lValue), .invalidCode(let rValue)):
            return lValue == rValue
        case (.missedIpHeader, .missedIpHeader),
             (.missedIcmpHeader, .missedIcmpHeader):
            return true
        default:
            return false
        }
    }
}
