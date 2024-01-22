// MARK: - PacketFactoryImpl

final class PacketFactoryImpl: PacketFactory {
    func create(type: PacketType) -> Packet {
        let packet: Packet
        
        switch type {
        case .icmp:
            packet = icmpPacket()
        }
        
        return packet
    }
}

// MARK: - Private API

private extension PacketFactoryImpl {
    func icmpPacket() -> Packet {
        var icmpHeader = ICMPHeader(
            type: .echoRequest,
            identifier: CFSwapInt16HostToBig(UInt16.random(in: 0..<UInt16.max)),
            sequenceNumber: CFSwapInt16HostToBig(UInt16.random(in: 0..<UInt16.max)),
            payload: Payload()
        )
        let checksum = ICMPChecksum()(header: icmpHeader)
        
        icmpHeader.setChecksum(checksum)
        
        return icmpHeader
    }
}
