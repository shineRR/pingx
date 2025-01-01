import Foundation
@testable import pingx

// MARK: - PacketFactoryMock

final class PacketFactoryMock: PacketFactory {
    private(set) var packetCreateCalledCount: Int = 0
    private(set) var packetCreateInvocations: [(identifier: UInt16, type: PacketType)] = []
    var error: Error?
    
    func create(identifier: UInt16, type: PacketType) throws -> Packet {
        packetCreateCalledCount += 1
        packetCreateInvocations.append((identifier, type))

        if let error { throw error }
        return PacketMock()
    }
}
