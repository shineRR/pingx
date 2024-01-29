import Foundation

// MARK: - Response

public struct Response {
    
    // MARK: Properties
    
    /// Destination address.
    let destination: IPv4Address
    
    /// Time elapsed between the request and the response. (ms)
    let duration: TimeInterval
}
