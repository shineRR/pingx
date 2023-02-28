//
// String+Extensions.swift
// pingx
//
// Created by Ilya Baryko on 24.10.22.
// 
//

import Foundation

public extension String {
    var socketAddress: sockaddr_in {
        var addr = sockaddr_in()
        addr.sin_len = UInt8(MemoryLayout.size(ofValue: addr))
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_addr.s_addr = inet_addr(self)
        inet_pton(AF_INET, self, &addr.sin_addr)
        return addr
    }
    
    var socketAddressData: Data {
        var addr = self.socketAddress
        let data = Data(bytes: &addr, count: MemoryLayout<sockaddr_in>.size)
        return data
    }
}
