//
// ICMPPackage.swift
// pingx
//
// Created by Ilya Baryko on 7.11.22.
// 
//

import Foundation

struct ICMPPackage {
    
    // MARK: - Properties
//    let ipHeader: IPHeader
    var icmpHeader: ICMPHeader
    
    // MARK: - Static
    static func echoRequestPackage() -> ICMPPackage {
        let icmpHeader = ICMPHeader(type: .echoRequest, code: .zero, checksum: .zero, data: .init())
        return ICMPPackage(icmpHeader: icmpHeader)
    }
    
    // MARK: - Methods
    mutating func toData(identifier: UInt16, sequenceNumber: UInt16) -> Data {
//        fatalError("TODO: - Implementation")
        let delta = 64 - MemoryLayout<uuid_t>.size
        var additional = [UInt8]()
        if delta > 0 {
            additional = (0..<delta).map { _ in UInt8.random(in: UInt8.min...UInt8.max) }
        }

        self.icmpHeader.checksum = ICMPHeader.checkSum(pointer: bytes, length: package.length)
        return Data(bytes: &self.icmpHeader, count: MemoryLayout<ICMPHeader>.size) + Data(additional)
    }
}
