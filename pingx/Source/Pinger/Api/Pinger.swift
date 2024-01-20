// MARK: - Pinger

public protocol Pinger: AnyObject {
    
    // MARK: Properties
    
    var delegate: PingerDelegate? { get set }
    
    // MARK: Methods
    
    func ping(request: Request)
}

// MARK: Default Implementation

extension Pinger {
    func extractResponse(from data: Data) -> IPHeader {
        data.withUnsafeBytes { $0.load(as: IPHeader.self) }
    }
}
