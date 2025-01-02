import Foundation

@testable import pingx

// MARK: - PacketMock

struct PacketMock: Packet {
    let data = Data()
}
