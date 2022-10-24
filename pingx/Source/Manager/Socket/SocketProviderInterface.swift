//
// SocketProviderInterface.swift
// pingx
//
// Created by Ilya Baryko on 23.10.22.
// 
//


import Foundation

public protocol SocketProviderInterface {
    func create(request: Request) -> CFSocket?
}
