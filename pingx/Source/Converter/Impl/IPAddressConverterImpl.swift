// MARK: - IPAddressConverter

public final class IPv4AddressConverter {
    public init() {}
}

// MARK: - IPv4AddressTupleConverter

extension IPv4AddressConverter: IPv4AddressTupleConverter {
    public func convert(address: (UInt8, UInt8, UInt8, UInt8)) -> IPv4Address {
        IPv4Address(address: address)
    }
}

// MARK: - IPv4AddressStringConverter

extension IPv4AddressConverter: IPv4AddressStringConverter {
    public func convert(address: String) throws -> IPv4Address {
        let allowedAddress = address.trimmingCharacters(in: Constants.allowedCharacters.inverted)
        let components = allowedAddress.components(separatedBy: ".").compactMap { UInt8($0) }
        guard components.count == Constants.ipv4Components else { throw IPAddressConverterError.invalidAddress }
        return IPv4Address(address: (components[0], components[1], components[2], components[3]))
    }
}

// MARK: - Constants

private extension IPv4AddressConverter {
    enum Constants {
        static var ipv4Components: Int { 4 }
        static var allowedCharacters: CharacterSet {
            CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "."))
        }
    }
}
