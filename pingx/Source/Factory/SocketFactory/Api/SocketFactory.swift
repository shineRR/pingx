// MARK: - SocketFactory

public protocol SocketFactory {
    func create(command: CommandBlock<Data>) throws -> CFSocket
}
