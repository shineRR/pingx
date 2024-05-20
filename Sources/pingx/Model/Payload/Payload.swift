import Foundation

// MARK: - Payload

struct Payload {
    
    // MARK: Typealias
    
    typealias PayloadID = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
    
    // MARK: Properties
    
    // "pingx"
    let identifier: PayloadID
    let timestamp: CFAbsoluteTime
    
    // MARK: Initializer
    
    init(
        identifier: PayloadID = (112, 105, 110, 103, 120, 0, 0, 0),
        timestamp: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
    ) {
        self.identifier = identifier
        self.timestamp = timestamp
    }
}
