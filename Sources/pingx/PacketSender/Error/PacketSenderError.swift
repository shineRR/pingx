import Foundation

// MARK: - PacketSenderError

enum PacketSenderError: Error {
    case socketCreationError
    case error
    case timeout
}
