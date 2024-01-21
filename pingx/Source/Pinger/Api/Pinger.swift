// MARK: - Pinger

public protocol Pinger: AnyObject {
    
    // MARK: Properties
    
    var delegate: PingerDelegate? { get set }
    
    // MARK: Methods
    
    func ping(request: Request)
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
}
