import Foundation

// MARK: - String+Extensions

public extension String {
    var socketAddress: Data {
        var socketAddress = sockaddr_in()
        
        socketAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        socketAddress.sin_family = UInt8(AF_INET)
        socketAddress.sin_port = .zero
        socketAddress.sin_addr.s_addr = inet_addr(cString(using: .utf8))
        
        return Data(bytes: &socketAddress, count: MemoryLayout<sockaddr_in>.size)
    }
}
