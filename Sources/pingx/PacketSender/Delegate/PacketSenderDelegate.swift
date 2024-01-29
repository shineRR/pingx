import Foundation

// MARK: - PacketSenderDelegate

protocol PacketSenderDelegate: AnyObject {
    func packetSender(packetSender: PacketSender, didReceive data: Data)
}
