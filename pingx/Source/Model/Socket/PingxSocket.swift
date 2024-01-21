// MARK: - Socket

final class PingxSocket<Instance: AnyObject> {
    
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
}
