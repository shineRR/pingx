//
//  ViewController.swift
//  pingx
//
//  Created by shineRR on 10/23/2022.
//  Copyright (c) 2022 shineRR. All rights reserved.
//

import UIKit
import pingx

class ViewController: UIViewController {

    // MARK: - Consts
    private enum Consts {
        static let destinationAddress = "8.8.8.8"
    }
    
    // MARK: - Properties
    private var pinger: Pinger?
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        self.test()
    }

    // MARK: - Methods
    private func test() {
        let pinger = Pinger(
            configuration: PingerConfiguration(timeoutInterval: 1000, packetsCount: 1),
            socketProvider: SocketProvider(),
            converter: IPAddressConverter(),
            delegate: self
        )
        pinger.ping(address: Consts.destinationAddress)
        self.pinger = pinger
    }

}

// MARK: - PingerDelegate
extension ViewController: PingerDelegate {
    func pinger(_ pinger: PingerInterface, request: Request, didReceive: Response) {
        print("didReceive")
    }
    
    func pinger(_ pinger: PingerInterface, request: Request, didCompleteWithError: Error) {
        print("didCompleteWithError")
    }
}
