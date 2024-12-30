import Foundation
@testable import pingx

// MARK: - PacketSenderMock

final class PacketSenderMock: PacketSender {
    
    // MARK: Delegate
    
    weak var delegate: PacketSenderDelegate?
    
    // MARK: Properties
    
//    var error: PacketSenderError?
    var sendError: Error?
    private(set) var sendCalledCount: Int = 0
    private(set) var sendCalledInvocation: [Request] = []
    private(set) var invalidateCalledCount: Int = 0
    
    func send(_ request: Request) throws {
        sendCalledCount += 1
        sendCalledInvocation.append(request)
        
        if let sendError { throw sendError }
    }
    
    func invalidate() {
        invalidateCalledCount += 1
    }
}

// MARK: - PacketSenderProtocol

//extension PacketSenderMock: PacketSender {
//    func send(_ request: Request) throws {
//        if let error { throw error }
//        guard request.demand != .unlimited else { return }
//        
//        if validationError == .missedIpHeader {
//            delegate?.packetSender(packetSender: self, didReceive: Data())
//            return
//        }
//        
//        var ipHeader = IPHeader(
//            totalLength: .zero,
//            headerChecksum: .zero,
//            sourceAddress: request.destination,
//            destinationAddress: .init(address: (127, 0, 0, 1))
//        )
//        
//        if validationError == .missedIcmpHeader(ipHeader) {
//            let data = Data(bytes: &ipHeader, count: MemoryLayout<IPHeader>.size)
//            delegate?.packetSender(packetSender: self, didReceive: data)
//            return
//        }
//        
//        var icmpHeader = ICMPHeader(
//            type: validationError == .invalidType(ipHeader) ? .routerSolicitation : .echoReply,
//            code: validationError == .invalidCode(ipHeader) ? UInt8.random(in: 200...255) : .zero,
//            identifier: .zero,
//            sequenceNumber: .zero,
//            payload: validationError == .invalidIdentifier(ipHeader) ? Constants.invalidPayload : Payload()
//        )
//        
//        if validationError != .checksumMismatch(ipHeader) {
//            do {
//                let checksum = try ICMPChecksum()(header: icmpHeader)
//                icmpHeader.setChecksum(checksum)
//            } catch {
//                throw PacketSenderError.error
//            }
//        }
//        
//        var icmp = ICMPPacket(ipHeader: ipHeader, icmpHeader: icmpHeader)
//        let data = Data(bytes: &icmp, count: MemoryLayout<ICMPPacket>.size)
//        
//        delegate?.packetSender(packetSender: self, didReceive: data)
//    }
//    
//    func invalidate() {
//        invalidateInvoked = true
//    }
//}

// MARK: - Constants

//private extension PacketSenderFake {
//    enum Constants {
//        static var invalidPayload: Payload { .init(identifier: (0, 0, 0, 0, 0, 0, 0, 0)) }
//    }
//}
