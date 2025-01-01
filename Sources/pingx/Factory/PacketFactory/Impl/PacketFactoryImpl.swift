import Foundation

// MARK: - PacketFactoryImpl

final class PacketFactoryImpl: PacketFactory {
    func create(identifier: UInt16, type: PacketType) throws -> Packet {
        let packet: Packet
        
        switch type {
        case .icmp:
            packet = try icmpPacket(identifier: identifier)
        }
        
        return packet
    }
}

// MARK: - Private API

private extension PacketFactoryImpl {
    func icmpPacket(identifier: UInt16) throws -> Packet {
        var icmpHeader = ICMPHeader(
            type: .echoRequest,
            identifier: identifier,
            sequenceNumber: CFSwapInt16HostToBig(UInt16.random(in: 0..<UInt16.max)),
            payload: Payload()
        )
        let checksum = try ICMPChecksum()(header: icmpHeader)
        
        icmpHeader.setChecksum(checksum)
        
        return icmpHeader
    }
}
