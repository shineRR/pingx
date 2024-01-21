// MARK: - Request

public struct Request {
    
    // MARK: Properties
    
    let type: PacketType = .icmp
    public let destination: IPv4Address
    public let timeoutInterval: TimeInterval
    private(set) var timeRemainingUntilDeadline: TimeInterval
    
    // MARK: Initializer
    
    public init(
        destination: IPv4Address,
        timeoutInterval: TimeInterval = 120
    ) {
        self.destination = destination
        self.timeoutInterval = timeoutInterval
        self.timeRemainingUntilDeadline = timeoutInterval
    }
    
    // MARK: Methods
    
    mutating func setTimeRemainingUntilDeadline(_ timeRemainingUntilDeadline: TimeInterval) {
        self.timeRemainingUntilDeadline = timeRemainingUntilDeadline
    }
}
