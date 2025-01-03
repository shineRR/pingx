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

struct ICMPHeader {
    
    // MARK: Properties
    
    let type: UInt8
    let code: UInt8
    private(set) var checksum: UInt16
    let identifier: UInt16
    let sequenceNumber: UInt16
    let payload: Payload
    
    // MARK: Initializer
    
    init(
        type: ICMPType,
        code: UInt8 = .zero,
        checksum: UInt16 = .zero,
        identifier: UInt16,
        sequenceNumber: UInt16,
        payload: Payload
    ) {
        self.type = type.rawValue
        self.code = code
        self.checksum = checksum
        self.identifier = identifier
        self.sequenceNumber = sequenceNumber
        self.payload = payload
    }
    
    // MARK: Methods
    
    mutating func setChecksum(_ checksum: UInt16) {
        self.checksum = checksum
    }
}

// MARK: - Packet

extension ICMPHeader: Packet {
    var data: Data {
        var packet = self
        return Data(bytes: &packet, count: MemoryLayout<ICMPHeader>.size)
    }
}
