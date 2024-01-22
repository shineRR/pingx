// MARK: - Pinger

public protocol Pinger: AnyObject {
    
    // MARK: Properties
    
    var delegate: PingerDelegate? { get set }
    
    // MARK: Methods
    
    func ping(request: Request)
    func stop(ipv4Address: IPv4Address)
}

// MARK: Default Implementation

extension Pinger {
    func extractICMPPackage(from data: Data) throws -> ICMPPackage {
        guard data.count >= MemoryLayout<IPHeader>.size + MemoryLayout<ICMPHeader>.size else {
            guard data.count >= MemoryLayout<IPHeader>.size else {
                throw ICMPResponseValidationError.missedIpHeader
            }
            let ipHeader = data.withUnsafeBytes { $0.load(as: IPHeader.self) }
            throw ICMPResponseValidationError.missedIcmpHeader(ipHeader)
        }
        
        let ipHeader = data.withUnsafeBytes { $0.load(as: IPHeader.self) }
        let offset = data.count - MemoryLayout<ICMPHeader>.size
        let icmpHeader = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: offset, as: ICMPHeader.self) }
        let icmpPackage = ICMPPackage(ipHeader: ipHeader, icmpHeader: icmpHeader)
        
        try validateICMPPackage(icmpPackage)
        
        return icmpPackage
    }
    
    private func validateICMPPackage(_ icmpPackage: ICMPPackage) throws {
        let identifier = Payload().identifier
        
        guard compareIdentifier(lhs: icmpPackage.icmpHeader.payload.identifier, rhs: identifier) else {
            throw ICMPResponseValidationError.invalidIdentifier(icmpPackage.ipHeader)
        }
        
        let checksum = ICMPChecksum()(header: icmpPackage.icmpHeader)
        
        guard icmpPackage.icmpHeader.checksum == checksum else {
            throw ICMPResponseValidationError.checksumMismatch(icmpPackage.ipHeader)
        }
        
        guard icmpPackage.icmpHeader.type == ICMPType.echoReply.rawValue else {
            throw ICMPResponseValidationError.invalidType(icmpPackage.ipHeader)
        }
        
        guard icmpPackage.icmpHeader.code == .zero else {
            throw ICMPResponseValidationError.invalidCode(icmpPackage.ipHeader)
        }
    }
    
    private func compareIdentifier(lhs: Payload.ID, rhs: Payload.ID) -> Bool {
        lhs.0 == rhs.0 &&
        lhs.1 == rhs.1 &&
        lhs.2 == rhs.2 &&
        lhs.3 == rhs.3 &&
        lhs.4 == rhs.4 &&
        lhs.5 == rhs.5 &&
        lhs.6 == rhs.6 &&
        lhs.7 == rhs.7
    }
}
