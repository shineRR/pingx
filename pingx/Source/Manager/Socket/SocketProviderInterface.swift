//
// SocketProviderInterface.swift
// pingx
//
// Created by Ilya Baryko on 23.10.22.
// 
//


import Foundation

public protocol SocketProviderInterface {
    func create(socketInfo: SocketInfo) throws -> CFSocket
    func invalidate(socket: CFSocket)
}
