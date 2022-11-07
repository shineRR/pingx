//
// SocketProvider.swift
// pingx
//
// Created by Ilya Baryko on 23.10.22.
// 
//


import Foundation

public final class SocketProvider: SocketProviderInterface {
    public init() { }
    
    public func create(socketInfo: SocketInfo) throws -> CFSocket {
        let socketInfo = Unmanaged.passRetained(socketInfo)
        var context = CFSocketContext(version: .zero, info: socketInfo.toOpaque(), retain: nil, release: nil, copyDescription: nil)
        let socket = CFSocketCreate(
            kCFAllocatorDefault,
            AF_INET,
            SOCK_DGRAM,
            IPPROTO_ICMP,
            CFSocketCallBackType.dataCallBack.rawValue, { socket, callbackType, address, data, info in
                guard let socket = socket,
                      let data = data,
                      let info = info,
                      (callbackType as CFSocketCallBackType) == CFSocketCallBackType.dataCallBack
                else { return }
                let socketInfo = Unmanaged<SocketInfo>.fromOpaque(info).takeUnretainedValue()
                let cfdata = Unmanaged<CFData>.fromOpaque(data).takeUnretainedValue()
                socketInfo.pinger?.receivedData(from: socket, cfdata as Data)
            },
            &context
        )

        let runLoopRef = CFSocketCreateRunLoopSource(
            kCFAllocatorDefault,
            socket,
            .zero
        )

        CFRunLoopAddSource(
            CFRunLoopGetCurrent(),
            runLoopRef,
            .commonModes
        )
    
        guard let socket = socket else { throw SocketProviderError.createError }
        
        return socket
    }
    
    public func invalidate(socket: CFSocket) {
        //
//        CFRunLoopSourceInvalidate(socket)
    }
}
