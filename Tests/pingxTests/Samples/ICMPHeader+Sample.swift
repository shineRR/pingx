@testable import pingx

extension ICMPHeader {
    static func sample(
        type: ICMPType = .echoReply,
        code: UInt8 = .zero,
        checksum: UInt16 = .zero,
        identifier: UInt16 = .zero,
        sequenceNumber: UInt16 = .zero,
        payload: Payload = Payload()
    ) -> ICMPHeader {
        ICMPHeader(
            type: type,
            code: code,
            checksum: checksum,
            identifier: identifier,
            sequenceNumber: sequenceNumber,
            payload: payload
        )
    }
}
