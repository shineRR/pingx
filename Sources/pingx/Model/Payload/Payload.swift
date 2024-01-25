import Foundation

// MARK: - Payload

struct Payload {
    
    // MARK: Typealias
    
    typealias ID = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
    
    // MARK: Properties
    
    // "pingx"
    let identifier: ID
    let timestamp: CFAbsoluteTime
    
    // MARK: Initializer
    
    init(
        identifier: ID = (112, 105, 110, 103, 120, 0, 0, 0),
        timestamp: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
    ) {
        self.identifier = identifier
        self.timestamp = timestamp
    }
}
