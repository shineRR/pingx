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
    let destinationAddress: IPAddress

    // MARK: - Init
    init(destinationAddress: IPAddress) {
        self.destinationAddress = destinationAddress
    }
}
