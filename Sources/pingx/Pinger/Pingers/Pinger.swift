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

public protocol PingerProtocol: AnyObject {
    func ping(request: Request, completion: @escaping (PingResult) -> Void)
    func cancel(requestId: Request.Identifier)
}

public final class Pinger: PingerProtocol {
    @Atomic private var activeTasks: [Request.Identifier: Task<Void, Never>] = [:]
    private let asyncPinger: AsyncPingerProtocol
    
    init(asyncPinger: AsyncPingerProtocol) {
        self.asyncPinger = asyncPinger
    }
    
    public convenience init(
        configuration: PingConfiguration = .default
    ) {
        self.init(
            asyncPinger: AsyncPinger(configuration: configuration)
        )
    }
    
    deinit {
        cancelAllActiveRequests()
    }
    
    public func ping(
        request: Request,
        completion: @escaping (PingResult) -> Void
    ) {
        var task: Task<Void, Never>?

        task = Task { [weak self] in
            let sequence = self?.asyncPinger.ping(request: request)

            while !Task.isCancelled, let result = try? await sequence?.next() as? PingResult {
                completion(result)
            }
            
            self?.cancel(requestId: request.identifier)
        }
        
        activeTasks[request.identifier] = task
    }

    public func cancel(requestId: Request.Identifier) {
        asyncPinger.cancel(requestId: requestId)

        let task = activeTasks.removeValue(forKey: requestId)
        task?.cancel()
    }
    
    private func cancelAllActiveRequests() {
        activeTasks.keys.forEach { cancel(requestId: $0) }
        activeTasks.removeAll()
    }
}
