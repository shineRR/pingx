//
// Request.swift
// pingx
//
// Created by Ilya Baryko on 23.10.22.
// 
//

import Foundation

public class Request {

    // MARK: - Properties
    let identifier = UUID().uuidString
    let ipv4Address: Data
    let destinationAddress: String

    // MARK: - Init
    init(destinationAddress: String) {
        self.ipv4Address = destinationAddress.socketAddressData
        self.destinationAddress = destinationAddress
    }
}
