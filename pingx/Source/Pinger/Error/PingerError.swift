// MARK: - PingerError

public enum PingerError: Error {
    case socketFailed
    case invalidAddress
    case timeout
}
