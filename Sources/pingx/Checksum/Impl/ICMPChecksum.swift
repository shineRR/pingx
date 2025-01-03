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

struct ICMPChecksum {
    func callAsFunction(icmpHeader: ICMPHeader) throws -> UInt16 {
        let typecode = Data([icmpHeader.type, icmpHeader.code]).withUnsafeBytes { $0.load(as: UInt16.self) }
        var sum = UInt64(typecode) + UInt64(icmpHeader.identifier) + UInt64(icmpHeader.sequenceNumber)
        let payload = arrayPayload(icmpHeader.payload)
        
        for i in stride(from: 0, to: payload.count, by: 2) {
            sum += Data([payload[i], payload[i + 1]]).withUnsafeBytes { UInt64($0.load(as: UInt16.self)) }
        }
        
        sum = (sum >> 16) + (sum & 0xFFFF)
        sum += sum >> 16
        
        guard sum >= UInt16.min, sum <= UInt16.max else { throw ChecksumError.outOfBounds }
        
        return ~UInt16(sum)
    }
}

extension ICMPChecksum {
    enum ChecksumError: Error {
        case outOfBounds
    }
}

private extension ICMPChecksum {
    func arrayPayload(_ payload: Payload) -> [UInt8] {
        let identifier: [UInt8] = [
            payload.identifier.0, payload.identifier.1, payload.identifier.2, payload.identifier.3,
            payload.identifier.4, payload.identifier.5, payload.identifier.6, payload.identifier.7
        ]
        var timestamp = payload.timestamp
        
        return identifier + Data(
            bytes: &timestamp,
            count: MemoryLayout<CFAbsoluteTime>.size
        ).withUnsafeBytes { Array($0) }
    }
}
