import Foundation

// MARK: - PacketSenderError

enum PacketSenderError: Error {
    case socketCreationError
    case unableToCreatePacket
    case error
    case timeout
}
