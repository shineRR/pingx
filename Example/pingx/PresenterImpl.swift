import pingx

// MARK: - PresenterImpl

final class PresenterImpl {
    
    // MARK: Properties
    
    private let pinger: Pinger
    
    // MARK: Initializer
    
    init(pinger: Pinger = ContinuousPinger()) {
        self.pinger = pinger
        pinger.delegate = self
    }
}

// MARK: - Presenter

extension PresenterImpl: Presenter {
    func didTapSendButton() {
        let request = Request(destination: Constants.destinationAddress, demand: .max(1))
        pinger.ping(request: request)
    }
}

// MARK: - PingerDelegate

extension PresenterImpl: PingerDelegate {
    func pinger(
        _ pinger: Pinger,
        request: Request,
        didReceive response: Response
    ) {
        print("Destination: \(request.destination)\nResponse: \(response)")
    }
    
    func pinger(
        _ pinger: Pinger,
        request: Request,
        didCompleteWithError error: PingerError
    ) {
        print("Destination: \(request.destination)\nError: \(error)")
    }
}

// MARK: - Constants

private extension PresenterImpl {
    enum Constants {
        static var destinationAddress: IPv4Address { .init(address: (8, 8, 8, 8)) }
    }
}
