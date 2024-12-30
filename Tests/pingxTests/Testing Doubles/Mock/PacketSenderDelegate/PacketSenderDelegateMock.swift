import Foundation

@testable import pingx

// MARK: - PacketSenderDelegateMock

final class PacketSenderDelegateMock: PacketSenderDelegate {
    private(set) var packetSenderCalledCount: Int = 0
    private(set) var packetSenderInvocations: [(packetSender: PacketSender, data: Data)] = []
    
    func packetSender(packetSender: PacketSender, didReceive data: Data) {
        packetSenderCalledCount += 1
        packetSenderInvocations.append((packetSender, data))
    }
}

