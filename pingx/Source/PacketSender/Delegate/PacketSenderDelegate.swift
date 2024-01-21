// MARK: - PacketSenderDelegate

protocol PacketSenderDelegate: AnyObject {
    func packetSender(packetSender: PacketSenderProtocol, didReceive data: Data)
}
