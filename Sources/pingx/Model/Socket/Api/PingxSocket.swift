import Foundation

// MARK: - PingxSocket

// sourcery: AutoMockable
protocol PingxSocket {
    
    // MARK: Typealias
    
    associatedtype Instance: AnyObject = CommandBlock<Data>
    
    // MARK: Methods
    
    func send(address: CFData, data: CFData, timeout: CFTimeInterval) -> CFSocketError
    func invalidate()
}
