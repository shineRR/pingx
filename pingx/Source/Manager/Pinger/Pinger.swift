//
// Pinger.swift
// pingx
//
// Created by Ilya Baryko on 23.10.22.
// 
//

import Foundation

public class Pinger: PingerInterface {
    
    // MARK: - Dependecies
    private let identifier = UInt16.random(in: 0..<UInt16.max)
    private let configuration: PingerConfiguration
    private let socketProvider: SocketProviderInterface
    private let converter: IPAddressConverterInterface
    
    // MARK: - Delegate
    private weak var delegate: PingerDelegate?
    
    // MARK: - Properties
    private var socket: CFSocket?
    
    // MARK: - Init
    public init(
        configuration: PingerConfiguration,
        socketProvider: SocketProviderInterface,
        converter: IPAddressConverterInterface,
        delegate: PingerDelegate
    ) {
        self.configuration = configuration
        self.socketProvider = socketProvider
        self.converter = converter
        self.delegate = delegate
    }
    
    // MARK: - Methods
    public func ping(address: IPAddress) {
        // TODO: - Implementation
//        let request = Request(destinationAddress: address)
//        do {
//            self.socket = try self.socketProvider.create(
//                request: request,
//                receivedData: self.receivedData(_:)
//            )
//            fatalError("Implementation")
//            self.start()
//        } catch {
//            self.socket = nil
//            self.delegate?.pinger(self, request: request, didCompleteWithError: error)
//        }
    }
    
    public func ping(address: String) {
        let request = Request(destinationAddress: address)
        guard self.converter.isValid(address: address) else {
            self.delegate?.pinger(self, request: request, didCompleteWithError: PingerError.invalidIp)
            return
        }
        do {
            let socketInfo = SocketInfo(address: address, pinger: self)
            self.socket = try self.socketProvider.create(
                socketInfo: socketInfo
            )
            self.start(request: request)
        } catch {
            self.socket = nil
            self.delegate?.pinger(self, request: request, didCompleteWithError: error)
        }
    }
    
    private func start(request: Request) {
        var icmpPackage = ICMPPackage.echoRequestPackage()
        
        let status = CFSocketSendData(self.socket,
                                      request.ipv4Address as CFData,
                                      icmpPackage.toData(identifier: self.identifier, sequenceNumber: .zero) as CFData,
                                      self.configuration.timeoutInterval)
        
        
        switch status {
        case .success:
            print("success")
        case .error:
            self.delegate?.pinger(self, request: request, didCompleteWithError: PingerError.invalidIp)
        case .timeout:
            self.delegate?.pinger(self, request: request, didCompleteWithError: PingerError.timeout)
        }

    }
}

extension Pinger {
    func receivedData(from socket: CFSocket, _ data: Data) {
        print(data)
    }
}
