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

public struct IPv4Address {

    // MARK: Properties
    
    public let address: (UInt8, UInt8, UInt8, UInt8)
    
    // MARK: Initializer
    
    public init(address: (UInt8, UInt8, UInt8, UInt8)) {
        self.address = address
    }
    
    public init(address: String) throws {
        let converter = IPv4AddressConverter()
        self.address = try converter.convert(address: address).address
    }
}

// MARK: - Hashable

extension IPv4Address: Hashable {
    public static func == (lhs: IPv4Address, rhs: IPv4Address) -> Bool {
        lhs.address.0 == rhs.address.0 &&
        lhs.address.1 == rhs.address.1 &&
        lhs.address.2 == rhs.address.2 &&
        lhs.address.3 == rhs.address.3
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(address.0)
        hasher.combine(address.1)
        hasher.combine(address.2)
        hasher.combine(address.3)
        _ = hasher.finalize()
    }
}

// MARK: - Internal API

extension IPv4Address {
    var stringAddress: String {
        "\(address.0).\(address.1).\(address.2).\(address.3)"
    }
    
    var socketAddress: Data {
        stringAddress.socketAddress
    }
}
