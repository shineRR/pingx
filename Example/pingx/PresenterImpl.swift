import pingx

// MARK: - Presenter

final class Presenter {
    
    // MARK: Constants

    enum Constants {
        static var destinationAddress: IPv4Address { IPv4Address(address: (8, 8, 8, 8)) }
    }
    
    // MARK: Properties
    
    private let pinger: Pinger
    
    // MARK: Initializer
    
    init(pinger: Pinger = Pinger()) {
        self.pinger = pinger
    }
    
    func didTapSendButton() {
        let request = Request(destination: Constants.destinationAddress, demand: .max(1))
        pinger.ping(request: request) { result in
            print(result)
        }
    }
}
