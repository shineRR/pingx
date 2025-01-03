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

public protocol Pinger: AnyObject {
    
    // MARK: Properties
    
    /// Notifies of the received event/error.
    var delegate: PingerDelegate? { get set }
    
    // MARK: Methods
    
    /// Starts pinging a specific `Request`.
    func ping(request: Request)
    
    /// Stops pinging a specific `Request`.
    func stop(request: Request)
    
    /// Stops pinging a specifc request ID.
    func stop(requestId: Request.ID)
}

// MARK: Default Implementation

extension Pinger {
    func extractICMPPackage(from data: Data) throws -> ICMPPacket {
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
    
    private func validateICMPPackage(_ icmpPackage: ICMPPacket) throws {
        let identifier = Payload().identifier
        
        guard compareIdentifier(lhs: icmpPackage.icmpHeader.payload.identifier, rhs: identifier) else {
            throw ICMPResponseValidationError.invalidPayload(icmpPackage.icmpHeader)
        }
        
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
    
    private func compareIdentifier(lhs: Payload.PayloadID, rhs: Payload.PayloadID) -> Bool {
        lhs.0 == rhs.0 &&
        lhs.1 == rhs.1 &&
        lhs.2 == rhs.2 &&
        lhs.3 == rhs.3 &&
        lhs.4 == rhs.4 &&
        lhs.5 == rhs.5 &&
        lhs.6 == rhs.6 &&
        lhs.7 == rhs.7
    }
}
