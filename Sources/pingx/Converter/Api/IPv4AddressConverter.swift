// MARK: - IPv4AddressStringConverter

public protocol IPv4AddressStringConverter {
    func convert(address: String) throws -> IPv4Address
}

// MARK: - IPv4AddressTupleConverter

public protocol IPv4AddressTupleConverter {
    func convert(address: (UInt8, UInt8, UInt8, UInt8)) -> IPv4Address
}
