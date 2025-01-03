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

public struct IPHeader {
    
    // MARK: Properties
    
    public let versionAndHeaderLength: UInt8
    public let serviceType: UInt8
    public let totalLength: UInt16 // Total length of the header and data portion of the packet, counted in octets.
    public let identifier: UInt16
    public let flagsAndFragmentOffset: UInt16 // Ripped from the IP protocol.
    public let timeToLive: UInt8
    public let `protocol`: UInt8
    public let headerChecksum: UInt16
    public let sourceAddress: IPv4Address
    public let destinationAddress: IPv4Address
    
    // MARK: Initializer
    
    init(
        versionAndHeaderLength: UInt8 = 4,
        serviceType: UInt8 = .zero,
        totalLength: UInt16,
        identifier: UInt16 = .zero,
        flagsAndFragmentOffset: UInt16 = .zero,
        timeToLive: UInt8 = 64,
        protocol: UInt8 = 1,
        headerChecksum: UInt16,
        sourceAddress: IPv4Address,
        destinationAddress: IPv4Address
    ) {
        self.versionAndHeaderLength = versionAndHeaderLength
        self.serviceType = serviceType
        self.totalLength = totalLength
        self.identifier = identifier
        self.flagsAndFragmentOffset = flagsAndFragmentOffset
        self.timeToLive = timeToLive
        self.protocol = `protocol`
        self.headerChecksum = headerChecksum
        self.sourceAddress = sourceAddress
        self.destinationAddress = destinationAddress
    }
}
