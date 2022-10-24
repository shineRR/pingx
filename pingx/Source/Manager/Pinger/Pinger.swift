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
    private let socketProvider: SocketProviderInterface
    private let converter: IPAddressConverterInterface
    
    // MARK: - Delegate
    private weak var delegate: PingerDelegate?
    
    // MARK: - Init
    public init(
        configuration: PingerConfiguration,
        socketProvider: SocketProviderInterface,
        converter: IPAddressConverterInterface,
        delegate: PingerDelegate
    ) {
        // configuration
        self.socketProvider = socketProvider
        self.converter = converter
        self.delegate = delegate
    }
    
    // MARK: - Methods
    public func ping(address: IPAddress) {
        // TODO: - Implementation
        let request = Request(destinationAddress: address)
        let socket = self.socketProvider.create(request: request)
        fatalError("Implementation")
        self.start()
    }
    
    public func ping(address: String) {
        guard
            let convertedAddress = try? self.converter.convert(address: address)
        else { return }
        
        self.ping(address: convertedAddress)
    }
    
    private func start() {
    }
}
