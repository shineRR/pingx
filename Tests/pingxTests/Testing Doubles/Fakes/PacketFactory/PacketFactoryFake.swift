import Foundation
@testable import pingx

// MARK: - PacketFactoryFake

final class PacketFactoryFake: PacketFactory {
    
    // MARK: Properties
    
    private let packetFactory = PacketFactoryImpl()
    var error: Error?
    
    // MARK: Methods
    
    func create(type: PacketType) throws -> Packet {
        if let error {
            throw error
        }
        
        return try packetFactory.create(type: type)
    }
}
