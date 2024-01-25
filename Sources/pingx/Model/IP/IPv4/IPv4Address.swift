import Foundation

// MARK: - IPv4Address

public struct IPv4Address {

    // MARK: Properties
    
    public let address: (UInt8, UInt8, UInt8, UInt8)
    
    // MARK: Initializer
    
    public init(address: (UInt8, UInt8, UInt8, UInt8)) {
        self.address = address
    }
    
    public init(address: String) throws {
        let converter = IPv4AddressConverter()
        self.address = try converter.convert(address: address).address
    }
}

// MARK: - Hashable

extension IPv4Address: Hashable {
    public static func == (lhs: IPv4Address, rhs: IPv4Address) -> Bool {
        lhs.address.0 == rhs.address.0 &&
        lhs.address.1 == rhs.address.1 &&
        lhs.address.2 == rhs.address.2 &&
        lhs.address.3 == rhs.address.3
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(address.0)
        hasher.combine(address.1)
        hasher.combine(address.2)
        hasher.combine(address.3)
        _ = hasher.finalize()
    }
}

// MARK: - Internal API

extension IPv4Address {
    var stringAddress: String {
        "\(address.0).\(address.1).\(address.2).\(address.3)"
    }
    
    var socketAddress: Data {
        stringAddress.socketAddress
    }
}
