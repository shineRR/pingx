import Foundation

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
        
        guard sum >= UInt16.min, sum <= UInt16.max else { throw ChecksumError.outOfBounds }
        
        return ~UInt16(sum)
    }
}

// MARK: - ChecksumError

extension ICMPChecksum {
    enum ChecksumError: Error {
        case outOfBounds
    }
}

// MARK: - Private API

private extension ICMPChecksum {
    private func arrayPayload(_ payload: Payload) -> [UInt8] {
        let identifier: [UInt8] = [
            payload.identifier.0, payload.identifier.1, payload.identifier.2, payload.identifier.3,
            payload.identifier.4, payload.identifier.5, payload.identifier.6, payload.identifier.7
        ]
        var timestamp = payload.timestamp
        
        return identifier + Data(
            bytes: &timestamp,
            count: MemoryLayout<CFAbsoluteTime>.size
        ).withUnsafeBytes { Array($0) }
    }
}
