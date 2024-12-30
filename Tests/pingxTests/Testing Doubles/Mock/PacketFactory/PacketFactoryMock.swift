import Foundation
@testable import pingx

// MARK: - PacketFactoryMock

final class PacketFactoryMock: PacketFactory {
    private(set) var packetCreateCalledCount: Int = 0
    private(set) var packetCreateInvocations: [PacketType] = []
    var error: Error?
    
    func create(type: PacketType) throws -> Packet {
        packetCreateCalledCount += 1
        packetCreateInvocations.append(type)

        if let error { throw error }
        return PacketMock()
    }
}
