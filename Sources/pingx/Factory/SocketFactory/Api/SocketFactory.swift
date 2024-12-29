import Foundation

// MARK: - SocketFactory

// sourcery: AutoMockable
protocol SocketFactory {
    func create(command: CommandBlock<Data>) throws -> any PingxSocket
}
