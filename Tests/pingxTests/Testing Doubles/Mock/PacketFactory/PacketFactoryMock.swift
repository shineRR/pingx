import Foundation
@testable import pingx

// MARK: - PacketFactoryMock

struct PacketMock: Packet {
    let data = Data()
}

final class PacketFactoryMock: PacketFactory {
    
    // MARK: Properties

    private(set) var packetCreateCalledCount: Int = 0
    private(set) var packetCreateInvocations: [PacketType] = []
    var error: Error?
    
    // MARK: Methods
    
    func create(type: PacketType) throws -> Packet {
        packetCreateCalledCount += 1
        packetCreateInvocations.append(type)

        if let error { throw error }
        return PacketMock()
    }
}
