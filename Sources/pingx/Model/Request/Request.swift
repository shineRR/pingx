import Foundation

// MARK: - Request

public struct Request: Identifiable {
    
    // MARK: Properties
    
    /// The unique identifier for the request.
    public let id = UUID()
    
    /// The type of protocol used to determine the ping.
    let type: PacketType = .icmp
    
    /// The destination IP.
    public let destination: IPv4Address
    
    /// Timeout interval.
    public let timeoutInterval: TimeInterval
    
    /// Time remaining until deadline.
    private(set) var timeRemainingUntilDeadline: TimeInterval
    
    /// The desired quantity of ping requests to be sent.
    public private(set) var demand: Request.Demand
    
    let sendTimeout: TimeInterval = .zero
    
    // MARK: Initializer
    
    public init(
        destination: IPv4Address,
        timeoutInterval: TimeInterval = 10,
        demand: Request.Demand = .max(1)
    ) {
        self.destination = destination
        self.timeoutInterval = timeoutInterval
        self.timeRemainingUntilDeadline = timeoutInterval
        self.demand = demand
    }
    
    // MARK: Methods
    
    mutating func setTimeRemainingUntilDeadline(_ timeRemainingUntilDeadline: TimeInterval) {
        self.timeRemainingUntilDeadline = timeRemainingUntilDeadline
    }
    
    mutating func setDemand(_ demand: Request.Demand) {
        self.demand = demand
    }
}

// MARK: - Demand

public extension Request {
    struct Demand: Equatable, Hashable {
        
        // MARK: Properties
        
        /// Represents the current demand, which indicates the number of values requested.
        public let max: Int?
        
        // MARK: Initializer
        
        init(max: Int?) {
            self.max = max
        }
        
        // MARK: Static
        
        /// A request for as many values as the pinger can produce.
        public static let unlimited = Request.Demand(max: nil)
        
        /// A request for no elements from the pinger.
        ///
        /// This is equivalent to `Demand.max(0)`.
        public static let none = Request.Demand(max: .zero)
        
        /// Creates a demand for the given maximum number of elements.
        ///
        /// - Parameter value: The maximum number of elements. Providing a negative value for this parameter results in a fatal error.
        public static func max(_ max: Int) -> Demand {
            guard max >= .zero else { FatalError.trigger("The value cannot be lower than 0.", #file, #line) }
            return .init(max: max)
        }
        
        static func - (lhs: Request.Demand, rhs: Request.Demand) -> Request.Demand {
            if lhs == .unlimited {
                return lhs
            } else if rhs == .unlimited {
                return .none
            } else {
                return .init(
                    max: Swift.max(
                        (lhs.max ?? .zero) - (rhs.max ?? .zero),
                        .zero
                    )
                )
            }
        }
        
        static func + (lhs: Request.Demand, rhs: Request.Demand) -> Request.Demand {
            if lhs == .unlimited || rhs == .unlimited { return .unlimited }
            return .init(
                max: (lhs.max ?? .zero) + (rhs.max ?? .zero)
            )
        }
    }
}
