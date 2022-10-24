//
// IPHeader.swift
// pingx
//
// Created by Ilya Baryko on 23.10.22.
// 
//

import Foundation

public typealias IPAddress = (UInt8, UInt8, UInt8, UInt8)

public struct IPHeader {
    public var versionAndHeaderLength: UInt8
    public var differentiatedServices: UInt8
    public var totalLength: UInt16
    public var identifier: UInt16
    public var flagsAndFragmentOffset: UInt16
    public var timeToLive: UInt8
    public var `protocol`: UInt8
    public var headerChecksum: UInt16
    public var sourceAddress: IPAddress
    public var destinationAddress: IPAddress
}
