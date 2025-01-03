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

import pingx
import Testing

@Suite
struct IPv4AddressConverterTests {
    @Test(
        "Convert a string value to an IPv4 address",
        arguments: [
            (address: "0.0.0.0", expectedResult: IPv4Address(address: (0, 0, 0, 0))),
            (address: "255.0.1.255", expectedResult: IPv4Address(address: (255, 0, 1, 255))),
            (address: "255.255.255.255", expectedResult: IPv4Address(address: (255, 255, 255, 255)))
        ]
    )
    func convert_returnsCorrectValue(address: String, expectedResult: IPv4Address) {
        let actualResult = try? IPv4AddressConverter().convert(address: address)
        
        #expect(actualResult == expectedResult)
    }
    
    @Test(
        "Convert a string value to an IPv4 address when the address is invalid",
        arguments: [
            "",
            "0.0.0",
            "255.0.1.255:10000",
            "255.255.255.255.1",
            "abc",
            "abc.abc.abc.abc",
            "abc1.ax3.4.5"
        ]
    )
    func convert_whenAddressIsInvalid_throwsInvalidAddressError(address: String) {
        #expect(throws: IPv4AddressConverterError.invalidAddress) {
            try IPv4AddressConverter().convert(address: address)
        }
    }
    
    @Test(
        "Convert a string value to an IPv4 address when an octet is out of range",
        arguments: [
            "-1.0.0.1",
            "1.256.999.1",
            "-1.-1.-1.-1"
        ]
    )
    func convert_whenOctetIsOutOfRange_throwsOctetOutOfRangeError(address: String) {
        #expect(throws: IPv4AddressConverterError.octetOutOfRange) {
            try IPv4AddressConverter().convert(address: address)
        }
    }
}
