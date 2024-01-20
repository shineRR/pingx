// MARK: - ICMPChecksum

struct ICMPChecksum {
    func callAsFunction(header: ICMPHeader) throws -> UInt16 {
        let typecode = Data([header.type, header.code]).withUnsafeBytes { $0.load(as: UInt16.self) }
        var sum = UInt64(typecode) + UInt64(header.identifier) + UInt64(header.sequenceNumber)
        let payload = arrayPayload(header.payload)
        
        for i in stride(from: 0, to: payload.count, by: 2) {
            sum += Data([payload[i], payload[i + 1]]).withUnsafeBytes { UInt64($0.load(as: UInt16.self)) }
        }
        
        sum = (sum >> 16) + (sum & 0xFFFF)
        sum += sum >> 16
        
        return ~UInt16(sum)
    }
}

// MARK: Private API

private extension ICMPChecksum {
    private func arrayPayload(_ payload: uuid_t) -> [UInt8] {
        return [
            payload.0, payload.1, payload.2, payload.3,
            payload.4, payload.5, payload.6, payload.7,
            payload.8, payload.9, payload.10, payload.11,
            payload.12, payload.13, payload.14, payload.15
        ].map { UInt8($0) }
    }
}
