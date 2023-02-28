//
// SocketInfo.swift
// pingx
//
// Created by Ilya Baryko on 24.10.22.
// 
//

import Foundation

public class SocketInfo {
    
    // MARK: - Properties
    let identifier = UUID().uuidString
    let address: String
    weak var pinger: Pinger?
    
    // MARK: - Initializer
    init(address: String, pinger: Pinger) {
        self.address = address
        self.pinger = pinger
    }
}
