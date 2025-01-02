import Foundation

@testable import pingx

// MARK: - PacketSenderDelegateMock

final class PacketSenderDelegateMock: PacketSenderDelegate {
    typealias ResponseInvocation = (packetSender: PacketSender, data: Data)
    typealias ErrorInvocation = (packetSender: PacketSender, request: Request, error: PacketSenderError)

    private(set) var didReceiveDataCalledCount: Int = 0
    private(set) var didReceiveDataInvocations: [ResponseInvocation] = []
    private(set) var didCompleteWithErrorCalledCount: Int = 0
    private(set) var didCompleteWithErrorInvocations: [ErrorInvocation] = []
    
    func packetSender(packetSender: PacketSender, didReceive data: Data) {
        didReceiveDataCalledCount += 1
        didReceiveDataInvocations.append((packetSender, data))
    }
    
    func packetSender(packetSender: PacketSender, request: Request, didCompleteWithError error: PacketSenderError) {
        didCompleteWithErrorCalledCount += 1
        didCompleteWithErrorInvocations.append((packetSender, request, error))
    }
}
