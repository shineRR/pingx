//
// The MIT License (MIT)
//
// Copyright © 2025 Ilya Baryka. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import pingx

final class CallbackPingViewModel: ObservableObject {
    private enum Constants {
        static var destinationAddress: IPv4Address { IPv4Address(address: (8, 8, 8, 8)) }
    }
    
    @Published private(set) var isPingActive = false
    @Published private(set) var pingResults = [PingResult]()
    
    private let pinger: PingerProtocol
    private var activeRequest: Request?
    
    init(pinger: PingerProtocol) {
        self.pinger = pinger
    }
    
    convenience init() {
        self.init(
            pinger: Pinger(
                configuration: PingConfiguration(intervalBetweenRequests: .milliseconds(500))
            )
        )
    }
    
    func startPinging() {
        pingResults.removeAll()
        
        let request = Request(
            destination: Constants.destinationAddress,
            demand: .max(5)
        )
        
        isPingActive = true
        activeRequest = request
        pinger.ping(request: request) { [weak self] result in
            DispatchQueue.main.async {
                self?.pingResults.append(result)
                
                if request.demand == .none {
                    self?.isPingActive = false
                }
            }
        }
    }
    
    func stopPinging() {
        isPingActive = false

        guard let activeRequest else { return }
        pinger.cancel(requestId: activeRequest.id)

        self.activeRequest = nil
    }
}
