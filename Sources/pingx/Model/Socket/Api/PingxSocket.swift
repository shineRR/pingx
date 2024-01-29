import Foundation

// MARK: - PingxSocket

protocol PingxSocket {
    
    // MARK: Typealias
    
    associatedtype Instance: AnyObject
    
    // MARK: Methods
    
    func send(address: CFData, data: CFData, timeout: CFTimeInterval) -> CFSocketError
    func invalidate()
}
