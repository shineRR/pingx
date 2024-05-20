import Foundation
@testable import pingx

// MARK: - MockPinger

final class MockPinger {
    
    // MARK: Delegate
    
    weak var delegate: PingerDelegate?
    
    // MARK: Properties
    
    private(set) var didReceiveInvoked = false
    private(set) var didReceiveData: Data?
    private(set) var pingInvoked = false
    private(set) var stopInvoked = false
    private(set) var receivedError: Error?
    private let packetSender: PacketSender
    
    // MARK: Initializer
    
    init(packetSender: PacketSender) {
        self.packetSender = packetSender
        packetSender.delegate = self
    }
}

// MARK: - Pinger

extension MockPinger: Pinger {
    func ping(request: Request) {
        pingInvoked = true
        
        do {
            try packetSender.send(request)
        } catch {
            receivedError = error
        }
    }
    
    func stop(ipv4Address: IPv4Address) {
        stopInvoked = true
    }
}

// MARK: - PacketSenderDelegate

extension MockPinger: PacketSenderDelegate {
    func packetSender(packetSender: PacketSender, didReceive data: Data) {
        didReceiveData = data
        didReceiveInvoked = true
    }
}
