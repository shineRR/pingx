// MARK: - Request

public struct Request: Identifiable {
    
    // MARK: Properties
    
    public let id: String = UUID().uuidString
    public let type: PacketType
    public let destination: IPv4Address
    public let timeoutInterval: TimeInterval
    
    // MARK: Initializer
    
    public init(
        type: PacketType, 
        destination: IPv4Address,
        timeoutInterval: TimeInterval = 120
    ) {
        self.type = type
        self.destination = destination
        self.timeoutInterval = timeoutInterval
    }
}
