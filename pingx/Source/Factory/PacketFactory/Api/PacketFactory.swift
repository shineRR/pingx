// MARK: - PacketFactory

protocol PacketFactory {
    func create(type: PacketType) throws -> Packet
}
