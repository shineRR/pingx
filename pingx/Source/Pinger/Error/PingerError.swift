// MARK: - PingerError

public enum PingerError: Error {
    case isOutgoing
    case socketFailed
    case invalidAddress
    case invalidResponseStructure
    case timeout
}
