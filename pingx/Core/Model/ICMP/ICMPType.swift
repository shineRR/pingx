//
// ICMPType.swift
// pingx
//
// Created by Ilya Baryko on 23.10.22.
// 
//

import Foundation
 
public enum ICMPType: UInt8 {
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
