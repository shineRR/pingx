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

// MARK: - Internal API

extension IPv4Address {
    var stringAddress: String {
        "\(address.0).\(address.1).\(address.2).\(address.3)"
    }
    
    var socketAddress: Data {
        stringAddress.socketAddress
    }
}
