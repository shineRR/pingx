import Foundation

// MARK: - PingerConfiguration

public struct PingerConfiguration {
    
    // MARK: Properties
    
    /// The interval between requests.
    public let interval: DispatchTimeInterval
    
    // MARK: Initializer
    
    public init(interval: DispatchTimeInterval = .seconds(1)) {
        self.interval = interval
    }
}
