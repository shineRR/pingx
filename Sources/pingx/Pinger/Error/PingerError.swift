import Foundation

// MARK: - PingerError

public enum PingerError: CustomNSError {
    public static let errorDomain: String = "com.pingx.PingerError"
    
    case pingInProgress
    case socketFailed
    case invalidDemand
    case invalidResponse
    case timeout
}
