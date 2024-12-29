// MARK: - PacketFactory

// sourcery: AutoMockable
protocol PacketFactory {
    func create(identifier: UInt16, type: PacketType) throws -> Packet
}
