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

import Foundation

public final class Request: Identifiable, Equatable {

    // MARK: Properties
    
    /// The unique identifier for the request.
    public let id: UInt16

    /// The type of icmp.
    let type: ICMPType = .echoRequest

    /// The destination IP.
    public let destination: IPv4Address
    
    /// Timeout interval (in milliseconds).
    public let timeoutInterval: TimeInterval
    
    /// The desired quantity of ping requests to be sent.
    private(set) var demand: Request.Demand
    
    // MARK: Initializer
    
    public init(
        destination: IPv4Address,
        timeoutInterval: TimeInterval = 1000,
        demand: Request.Demand = .max(1)
    ) {
        self.id = CFSwapInt16HostToBig(UInt16.random(in: 0..<UInt16.max))
        self.destination = destination
        self.timeoutInterval = timeoutInterval
        self.demand = demand
    }

    init(
        id: UInt16,
        destination: IPv4Address,
        timeoutInterval: TimeInterval,
        demand: Request.Demand
    ) {
        self.id = id
        self.destination = destination
        self.timeoutInterval = timeoutInterval
        self.demand = demand
    }
    
    // MARK: Methods

    public static func == (lhs: Request, rhs: Request) -> Bool {
        lhs.id == rhs.id && lhs.destination == rhs.destination
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(type)
        hasher.combine(destination)
        hasher.combine(timeoutInterval)
    }

    func decreaseDemand() {
        demand = demand - .max(1)
    }
}

// MARK: - Demand

public extension Request {
    struct Demand: Equatable {
        
        // MARK: Properties
        
        /// Represents the current demand, which indicates the number of values requested.
        public let max: Int?
        
        // MARK: Initializer
        
        init(max: Int?) {
            self.max = max
        }
        
        // MARK: Static
        
        /// A request for as many values as the pinger can produce.
        public static let unlimited = Request.Demand(max: nil)
        
        /// A request for no elements from the pinger.
        ///
        /// This is equivalent to `Demand.max(0)`.
        public static let none = Request.Demand(max: .zero)
        
        /// Creates a demand for the given maximum number of elements.
        ///
        /// - Parameter value: The maximum number of elements. Providing a negative value for this parameter results in a fatal error.
        public static func max(_ max: Int) -> Demand {
            guard max >= .zero else { FatalError.trigger("The value cannot be lower than 0.", #file, #line) }
            return .init(max: max)
        }
        
        static func - (lhs: Request.Demand, rhs: Request.Demand) -> Request.Demand {
            if lhs == .unlimited {
                return lhs
            } else if rhs == .unlimited {
                return .none
            } else {
                return .init(
                    max: Swift.max(
                        (lhs.max ?? .zero) - (rhs.max ?? .zero),
                        .zero
                    )
                )
            }
        }
        
        static func + (lhs: Request.Demand, rhs: Request.Demand) -> Request.Demand {
            if lhs == .unlimited || rhs == .unlimited { return .unlimited }
            return .init(
                max: (lhs.max ?? .zero) + (rhs.max ?? .zero)
            )
        }
    }
}
