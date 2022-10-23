//
// SocketProvider.swift
// pingx
//
// Created by Ilya Baryko on 23.10.22.
// 
//


import Foundation

public final class SocketProvider: SocketProviderInterface {
    public func create(request: Request) -> CFSocket? {
        let requestInfo = Unmanaged.passRetained(request)
        var context = CFSocketContext(version: .zero, info: requestInfo.toOpaque(), retain: nil, release: nil, copyDescription: nil)
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
                let cfdata = Unmanaged<CFData>.fromOpaque(data).takeUnretainedValue()

            },
            &context
        )
        
        return socket
    }
}
