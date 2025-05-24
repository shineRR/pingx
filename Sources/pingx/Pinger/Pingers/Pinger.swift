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

protocol PingerProtocol: AnyObject {
    func ping(request: Request, completion: @escaping (PingResult) -> Void)
    func cancel(request: Request)
}

final class Pinger: PingerProtocol {
    private let asyncPinger: AsyncPingerProtocol
    @Atomic private var activeRequests: [UInt16: Request] = [:]
    
    init(asyncPinger: AsyncPingerProtocol) {
        self.asyncPinger = asyncPinger
    }
    
    convenience init() {
        self.init(
            asyncPinger: AsyncPinger()
        )
    }
    
    deinit {
        cancelAllActiveRequests()
    }
    
    func ping(
        request: Request,
        completion: @escaping (PingResult) -> Void
    ) {
        activeRequests = [request.id: request]

        Task { [weak self] in
            var sequence = self?.asyncPinger.ping(request: request)

            while let result = try? await sequence?.next() {
                completion(result)
            }
            
            self?.cancel(request: request)
        }
    }

    func cancel(request: Request) {
        activeRequests.removeValue(forKey: request.id)
        asyncPinger.cancel(request: request)
    }
    
    private func cancelAllActiveRequests() {
        activeRequests.values.forEach { request in
            cancel(request: request)
        }
    }
}
