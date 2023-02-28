//
// IPAddressConverter.swift
// pingx
//
// Created by Ilya Baryko on 23.10.22.
// 
//

import Foundation

public final class IPAddressConverter: IPAddressConverterInterface {
    
    // MARK: - Consts
    private enum Consts {
        static let ipv4Components = 4
        static let allowedCharacters = CharacterSet.decimalDigits
            .union(CharacterSet(charactersIn: "."))
    }
    
    public init() { }
    
    // MARK: - Methods
    public func isValid(address: String) -> Bool {
        let allowedAddress = address.trimmingCharacters(in: Consts.allowedCharacters.inverted)
        let components = allowedAddress.components(separatedBy: ".").compactMap { UInt8($0) }
        return components.count == Consts.ipv4Components
    }
    
    public func convert(address: String) throws -> IPAddress {
        let allowedAddress = address.trimmingCharacters(in: Consts.allowedCharacters.inverted)
        let components = allowedAddress.components(separatedBy: ".").compactMap { UInt8($0) }
        guard components.count == Consts.ipv4Components else { throw IPAddressConverterError.invalidAddress }
        return IPAddress(components[0], components[1], components[2], components[3])
    }
}
