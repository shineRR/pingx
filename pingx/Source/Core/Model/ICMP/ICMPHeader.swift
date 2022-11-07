//
// ICMPHeader.swift
// pingx
//
// Created by Ilya Baryko on 23.10.22.
// 
//

import Foundation

public struct ICMPHeader {
    public let type: ICMPType
    public let code: UInt8
    public var checksum: UInt16
    public var data: Data
}

extension ICMPHeader {
    static func checkSum(pointer: UnsafeMutableRawPointer, length: Int) -> UInt16 {
        var sum = UInt32.zero
        var length = length
        var bufferPointer = pointer.assumingMemoryBound(to: UInt16.self)
        
        while length > 1 {
            sum += UInt32(bufferPointer.pointee)
            bufferPointer = bufferPointer.successor()
            length -= MemoryLayout<UInt16>.size
        }

        if length == 1 {
            sum += UInt32(UnsafeMutablePointer<UInt16>(bufferPointer).pointee)
        }
        
        sum = (sum >> 16) + (sum & 0xffff)
        sum += (sum >> 16)
        
        return UInt16(truncating: sum as NSNumber)
    }
}
