//
// IPAddressConverterInterface.swift
// pingx
//
// Created by Ilya Baryko on 23.10.22.
// 
//

import Foundation

public protocol IPAddressConverterInterface {
    func convert(address: String) throws -> IPAddress
}
