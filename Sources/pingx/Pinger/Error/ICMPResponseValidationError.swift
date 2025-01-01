// MARK: - ICMPResponseValidationError

enum ICMPResponseValidationError: Error {
    var icmpHeader: ICMPHeader? {
        switch self {
        case .checksumMismatch(let icmpHeader),
             .invalidCode(let icmpHeader),
             .invalidType(let icmpHeader),
             .invalidPayload(let icmpHeader):
            return icmpHeader
        case .missedIpHeader, .missedIcmpHeader:
            return nil
        }
    }
    
    case checksumMismatch(ICMPHeader)
    case invalidPayload(ICMPHeader)
    case invalidType(ICMPHeader)
    case invalidCode(ICMPHeader)
    case missedIpHeader
    case missedIcmpHeader
}
