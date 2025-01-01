@testable import pingx

// MARK: - Equatable

extension ICMPResponseValidationError: Equatable {
    public static func == (lhs: ICMPResponseValidationError, rhs: ICMPResponseValidationError) -> Bool {
        switch (lhs, rhs) {
        case (.checksumMismatch, .checksumMismatch),
             (.invalidPayload, .invalidPayload),
             (.invalidType, .invalidType),
             (.invalidCode, .invalidCode),
             (.missedIpHeader, .missedIpHeader),
             (.missedIcmpHeader, .missedIcmpHeader):
            return true
        default:
            return false
            
        }
    }
}
