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
    func cancel(request: Request)
}

public final class Pinger: PingerProtocol {
    private let asyncPinger: AsyncPingerProtocol
    @Atomic private var activeTasks: [UInt16: Task<Void, Never>] = [:]
    
    init(asyncPinger: AsyncPingerProtocol) {
        self.asyncPinger = asyncPinger
    }
    
    public convenience init() {
        self.init(
            asyncPinger: AsyncPinger()
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
            var sequence = self?.asyncPinger.ping(request: request)

            while !Task.isCancelled, let result = try? await sequence?.next() as? PingResult {
                completion(result)
            }
            
            self?.cancel(request: request)
        }
        
        activeTasks[request.id] = task
    }

    public func cancel(request: Request) {
        asyncPinger.cancel(request: request)

        let task = activeTasks.removeValue(forKey: request.id)
        task?.cancel()
    }
    
    private func cancelAllActiveRequests() {
        activeTasks.values.forEach { $0.cancel() }
        activeTasks.removeAll()
    }
}
