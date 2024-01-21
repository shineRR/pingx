// MARK: - ICMPResponseValidationError

enum ICMPResponseValidationError: Error {
    case checksumMismatch(IPHeader)
    case invalidType(IPHeader)
    case invalidCode(IPHeader)
    case missedIpHeader
    case missedIcmpHeader(IPHeader)
}
