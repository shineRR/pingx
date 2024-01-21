// MARK: - SocketFactory

protocol SocketFactory {
    func create(command: CommandBlock<Data>) throws -> PingxSocket<CommandBlock<Data>>
}
