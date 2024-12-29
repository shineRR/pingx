// MARK: - PacketSender

// sourcery: AutoMockable
protocol PacketSender: AnyObject {
    
    // MARK: Delegate
    
    var delegate: PacketSenderDelegate? { get set }
    
    // MARK: Methods
    
    func send(_ request: Request)
    func invalidate()
}
