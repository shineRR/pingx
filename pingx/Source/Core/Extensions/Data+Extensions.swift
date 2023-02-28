//
// Data+Extensions.swift
// pingx
//
// Created by Ilya Baryko on 24.10.22.
// 
//

import Foundation

public extension Data {
    var socketAddress: sockaddr {
        return withUnsafeBytes { $0.load(as: sockaddr.self) }
    }
    
    var socketAddressInternet: sockaddr_in {
        return withUnsafeBytes { $0.load(as: sockaddr_in.self) }
    }
}
