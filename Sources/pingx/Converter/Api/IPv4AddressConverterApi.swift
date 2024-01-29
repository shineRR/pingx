// MARK: - IPv4AddressStringConverter

public protocol IPv4AddressStringConverter {
    
    /// Converts `address` to IPv4Address.
    func convert(address: String) throws -> IPv4Address
}

// MARK: - IPv4AddressTupleConverter

public protocol IPv4AddressTupleConverter {
    
    /// Converts `address` to IPv4Address.
    func convert(address: (UInt8, UInt8, UInt8, UInt8)) -> IPv4Address
}
