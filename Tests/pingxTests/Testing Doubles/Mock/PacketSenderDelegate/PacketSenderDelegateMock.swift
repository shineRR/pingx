import Foundation

@testable import pingx

// MARK: - PacketSenderDelegateMock

final class PacketSenderDelegateMock: PacketSenderDelegate {
    typealias ResponseInvocation = (packetSender: PacketSender, data: Data)
    typealias ErrorInvocation = (packetSender: PacketSender, request: Request, error: PacketSenderError)

    private(set) var packetSenderDidReceiveDataCalledCount: Int = 0
    private(set) var packetSenderDidReceiveDataInvocations: [ResponseInvocation] = []
    private(set) var packetSenderDidCompleteWithErrorCalledCount: Int = 0
    private(set) var packetSenderDidCompleteWithErrorInvocations: [ErrorInvocation] = []
    
    func packetSender(packetSender: PacketSender, didReceive data: Data) {
        packetSenderDidReceiveDataCalledCount += 1
        packetSenderDidReceiveDataInvocations.append((packetSender, data))
    }
    
    func packetSender(packetSender: PacketSender, request: Request, didCompleteWithError error: PacketSenderError) {
        packetSenderDidCompleteWithErrorCalledCount += 1
        packetSenderDidCompleteWithErrorInvocations.append((packetSender, request, error))
    }
}
