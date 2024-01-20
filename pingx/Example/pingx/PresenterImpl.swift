import pingx

// MARK: - PresenterImpl

final class PresenterImpl {
    
    // MARK: Properties
    
    private let pinger: Pinger
    
    // MARK: Initializer
    
    init(pinger: Pinger = SinglePinger()) {
        self.pinger = pinger
        self.pinger.delegate = self
    }
}

// MARK: - Presenter

extension PresenterImpl: Presenter {
    func didTapSendButton() {
        let request = Request(type: .icmp, destination: Constants.destinationAddress)
        pinger.ping(request: request)
    }
}

extension PresenterImpl: PingerDelegate {
    func pinger(
        _ pinger: Pinger,
        request: Request,
        didReceive response: Response
    ) {
        print(response)
    }
    
    func pinger(
        _ pinger: Pinger,
        request: Request,
        didCompleteWithError error: PingerError
    ) {
        print(error)
    }
}

// MARK: - Constants

private extension PresenterImpl {
    enum Constants {
        static var destinationAddress: IPv4Address { .init(address: (8, 8, 8, 8)) }
    }
}

