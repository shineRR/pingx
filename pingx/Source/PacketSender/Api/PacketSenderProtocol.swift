// MARK: - PacketSender

protocol PacketSenderProtocol {
    func send(_ request: Request) throws
}
