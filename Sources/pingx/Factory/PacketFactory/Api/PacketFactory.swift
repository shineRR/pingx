// MARK: - PacketFactory

protocol PacketFactory {
    func create(identifier: UInt16, type: PacketType) throws -> Packet
}
