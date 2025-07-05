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

// sourcery: AutoMockable
protocol ICMPPacketExtractorProtocol {
    func extract(from data: Data) throws -> ICMPPacket
}

struct ICMPPacketExtractor: ICMPPacketExtractorProtocol {
    func extract(from data: Data) throws -> ICMPPacket {
        guard data.count >= MemoryLayout<IPHeader>.size + MemoryLayout<ICMPHeader>.size else {
            guard data.count >= MemoryLayout<IPHeader>.size else {
                throw ICMPResponseValidationError.missedIpHeader
            }
            throw ICMPResponseValidationError.missedIcmpHeader
        }

        let ipHeader = data.withUnsafeBytes { $0.load(as: IPHeader.self) }
        let offset = data.count - MemoryLayout<ICMPHeader>.size
        let icmpHeader = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: offset, as: ICMPHeader.self) }
        let icmpPackage = ICMPPacket(ipHeader: ipHeader, icmpHeader: icmpHeader)

        try validateICMPPackage(icmpPackage)

        return icmpPackage
    }
}

private extension ICMPPacketExtractor {
    func validateICMPPackage(_ icmpPackage: ICMPPacket) throws(ICMPResponseValidationError) {
        guard icmpPackage.icmpHeader.type == ICMPType.echoReply.rawValue else {
            throw ICMPResponseValidationError.invalidType(icmpPackage.icmpHeader)
        }

        guard icmpPackage.icmpHeader.code == .zero else {
            throw ICMPResponseValidationError.invalidCode(icmpPackage.icmpHeader)
        }

        do {
            let checksum = try ICMPChecksum()(icmpHeader: icmpPackage.icmpHeader)

            guard icmpPackage.icmpHeader.checksum == checksum else {
                throw ICMPResponseValidationError.checksumMismatch(icmpPackage.icmpHeader)
            }
        } catch {
            throw ICMPResponseValidationError.checksumMismatch(icmpPackage.icmpHeader)
        }
    }
}
