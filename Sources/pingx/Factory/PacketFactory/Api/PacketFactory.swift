// MARK: - PacketFactory

protocol PacketFactory {
    func create(type: PacketType) -> Packet
}
