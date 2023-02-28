//
// PingerConfiguration.swift
// pingx
//
// Created by Ilya Baryko on 23.10.22.
// 
//

import Foundation

public struct PingerConfiguration {
    let timeoutInterval: TimeInterval
    let packetsCount: Int
    
    public init(timeoutInterval: TimeInterval, packetsCount: Int) {
        self.timeoutInterval = timeoutInterval
        self.packetsCount = packetsCount
    }
}
//open class PingerConfiguration: PingerConfigurationInterface {
//
//}
