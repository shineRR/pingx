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

public struct Request: Hashable, Sendable {

    public typealias Identifier = PingxIdentifier

    // MARK: Properties

    /// The unique identifier for the request.
    public let identifier: Identifier

    /// The type of icmp.
    let type: ICMPType = .echoRequest

    /// The destination IP.
    public let destination: IPv4Address

    /// Timeout interval.
    public let timeoutInterval: Interval

    /// The desired quantity of ping requests to be sent.
    public private(set) var demand: Request.Demand

    /// A sequence number  to help in matching Echo and Echo Reply messages.
    private(set) var sequenceNumber: UInt16

    // MARK: Initializer

    public init(
        destination: IPv4Address,
        timeoutInterval: Interval = .seconds(1),
        demand: Request.Demand = .max(1)
    ) {
        self.identifier = Identifier()
        self.destination = destination
        self.timeoutInterval = timeoutInterval
        self.demand = demand
        self.sequenceNumber = .zero
    }

    init(
        id: Identifier,
        destination: IPv4Address,
        timeoutInterval: Interval,
        demand: Request.Demand,
        sequenceNumber: UInt16
    ) {
        self.identifier = id
        self.destination = destination
        self.timeoutInterval = timeoutInterval
        self.demand = demand
        self.sequenceNumber = sequenceNumber
    }

    // MARK: Methods

    public static func == (lhs: Request, rhs: Request) -> Bool {
        lhs.identifier == rhs.identifier && lhs.destination == rhs.destination
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
        hasher.combine(type)
        hasher.combine(destination)
        hasher.combine(timeoutInterval)
        hasher.combine(demand)
        hasher.combine(sequenceNumber)
    }

    mutating func setDemand(_ demand: Demand) {
        self.demand = demand
    }

    mutating func decreaseDemand() {
        demand = demand - .max(1)
    }

    mutating func incrementSequenceNumber() {
        let (result, overflow) = sequenceNumber.addingReportingOverflow(1)
        sequenceNumber = overflow ? .zero : result
    }
}

// MARK: - Demand

public extension Request {
    struct Demand: Hashable, Sendable {

        // MARK: Properties

        /// Represents the current demand, which indicates the number of values requested.
        public let max: UInt?

        // MARK: Initializer

        init(max: UInt?) {
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
        /// - Parameter value: The maximum number of elements.
        public static func max(_ max: UInt) -> Demand {
            Demand(max: max)
        }

        static func - (lhs: Request.Demand, rhs: Request.Demand) -> Request.Demand {
            if lhs == .unlimited {
                return lhs
            } else if rhs == .unlimited {
                return .none
            } else {
                let lValue = lhs.max ?? .zero
                let rValue = rhs.max ?? .zero

                let (result, overflow) = lValue.subtractingReportingOverflow(rValue)
                return overflow ? .none : .max(result)
            }
        }

        static func + (lhs: Request.Demand, rhs: Request.Demand) -> Request.Demand {
            if lhs == .unlimited || rhs == .unlimited { return .unlimited }

            let lValue = lhs.max ?? .zero
            let rValue = rhs.max ?? .zero

            let (result, overflow) = lValue.addingReportingOverflow(rValue)
            return overflow ? .max(.max) : .max(result)
        }
    }
}
