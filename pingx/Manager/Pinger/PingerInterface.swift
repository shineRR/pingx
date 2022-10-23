//
// PingerInterface.swift
// pingx
//
// Created by Ilya Baryko on 23.10.22.
// 
//

import Foundation

public protocol PingerInterface {
    func ping(address: IPAddress)
    func ping(address: String)
}
