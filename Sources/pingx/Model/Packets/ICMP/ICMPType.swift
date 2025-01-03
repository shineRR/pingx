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

enum ICMPType: UInt8 {
    
    /// Echo reply (used to ping)
    case echoReply = 0
    
    /// Destination network unreachable
    case destinationUnreachable = 3
    
    /// Source quench (congestion control)
    case sourceQuench = 4
    
    /// Redirect Datagram for the Network
    case redirectMessage = 5
    
    /// Echo request (used to ping)
    case echoRequest = 8
    
    /// Router Advertisement
    case routerAdvertisement = 9
    
    /// Router discovery/selection/solicitation
    case routerSolicitation = 10
    
    /// TTL expired in transit / Fragment reassembly time exceeded
    case timeExceeded = 11
    
    /// Parameter Problem: Bad IP header
    case badIpHeader = 12
    
    /// Timestamp
    case timestamp = 13
    
    /// Timestamp reply
    case timestampReply = 14
    
    /// Information Request(deprecated
    case informationRequest = 15
    
    /// Information Reply(deprecated)
    case informationReply = 16
    
    /// Address Mask Request(deprecated)
    case addressMaskRequest = 17
    
    /// Address Mask Reply(deprecated)
    case addressMaskReply = 18
    
    /// Request Extended Echo (XPing)
    case extendedEchoRequest = 42
    
    // Extended Echo Reply
    case extendedEchoReply = 43
}
