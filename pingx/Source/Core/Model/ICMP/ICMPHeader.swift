//
// ICMPHeader.swift
// pingx
//
// Created by Ilya Baryko on 23.10.22.
// 
//

import Foundation

public protocol ICMPHeader {
    var type: ICMPType { get }
    var code: UInt8 { get }
    var checksum: UInt16 { get }
    var data: Data { get }
}
