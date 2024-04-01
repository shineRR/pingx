import Foundation

// MARK: - Response

public struct Response {
    
    // MARK: Properties
    
    /// Destination address.
    public let destination: IPv4Address
    
    /// Time elapsed between the request and the response. (ms)
    public let duration: TimeInterval
}
