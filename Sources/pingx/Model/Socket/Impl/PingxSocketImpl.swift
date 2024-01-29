import Foundation

// MARK: - PingxSocketImpl

final class PingxSocketImpl<T: AnyObject>: PingxSocket {
    
    // MARK: Typealias
    
    typealias Instance = T
    
    // MARK: Properties
    
    let socket: CFSocket
    let socketSource: CFRunLoopSource
    let unmanaged: Unmanaged<Instance>
    
    // MARK: Initializer
    
    init(
        socket: CFSocket,
        socketSource: CFRunLoopSource,
        unmanaged: Unmanaged<Instance>
    ) {
        self.socket = socket
        self.socketSource = socketSource
        self.unmanaged = unmanaged
    }
    
    // MARK: Methods
    
    func send(address: CFData, data: CFData, timeout: CFTimeInterval) -> CFSocketError {
        CFSocketSendData(
            socket,
            address,
            data as CFData,
            timeout
        )
    }
    
    func invalidate() {
        CFRunLoopSourceInvalidate(socketSource)
        CFSocketInvalidate(socket)
        unmanaged.release()
    }
}
