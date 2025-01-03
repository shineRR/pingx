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

public struct IPv4AddressConverter: IPv4AddressStringConverter {
    private enum Constants {
        static var ipv4OctetsCount: Int { 4 }
        static var allowedCharacters: CharacterSet {
            CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ".-"))
        }
    }

    public init() {}

    public func convert(address: String) throws -> IPv4Address {
        let components = address.trimmingCharacters(in: Constants.allowedCharacters.inverted)
            .components(separatedBy: ".")
            .compactMap(Int.init)
        guard components.count == Constants.ipv4OctetsCount else { throw IPAddressConverterError.invalidAddress }
        
        let ipv4Octets = components.compactMap(UInt8.init)
        guard ipv4Octets.count == Constants.ipv4OctetsCount else { throw IPAddressConverterError.octetOutOfRange }

        return IPv4Address(address: (ipv4Octets[0], ipv4Octets[1], ipv4Octets[2], ipv4Octets[3]))
    }
}
