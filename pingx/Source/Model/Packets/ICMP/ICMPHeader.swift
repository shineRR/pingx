// MARK: - ICMPHeader

struct ICMPHeader {
    
    // MARK: Properties
    
    let type: UInt8
    let code: UInt8
    private(set) var checksum: UInt16
    let identifier: UInt16
    let sequenceNumber: UInt16
    /// 16 bytes.
    let payload: Payload
    
    // MARK: Initializer
    
    init(
        type: ICMPType,
        code: UInt8 = .zero,
        checksum: UInt16 = .zero,
        identifier: UInt16,
        sequenceNumber: UInt16,
        payload: Payload
    ) {
        self.type = type.rawValue
        self.code = code
        self.checksum = checksum
        self.identifier = identifier
        self.sequenceNumber = sequenceNumber
        self.payload = payload
    }
    
    // MARK: Methods
    
    mutating func setChecksum(_ checksum: UInt16) {
        self.checksum = checksum
    }
}

// MARK: - Packet

extension ICMPHeader: Packet {
    var data: Data {
        var packet = self
        return Data(bytes: &packet, count: MemoryLayout<ICMPHeader>.size)
    }
}
