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

import Testing

@testable import pingx

@Suite
struct DemandTests {
    typealias Demand = Request.Demand

    @Test(
        "Tests initialization of demand",
        arguments: [
            (demand: Demand.none, expectedValue: UInt(0)),
            (demand: Demand.unlimited, expectedValue: nil),
            (demand: Demand.max(2), expectedValue: UInt(2)),
        ]
    )
    func demand_initialization(demand: Demand, expectedValue: UInt?) {
        #expect(demand.max == expectedValue)
    }

    @Test(
        "Tests demand substraction",
        arguments: [
            (lValue: Demand.unlimited, rValue: Demand.unlimited, result: Demand.unlimited),
            (lValue: Demand.unlimited, rValue: Demand.max(3), result: Demand.unlimited),
            (lValue: Demand.max(3), rValue: Demand.unlimited, result: Demand.none),
            (lValue: Demand.max(3), rValue: Demand.max(3), result: Demand.none),
            (lValue: Demand.max(3), rValue: Demand.max(2), result: Demand.max(1)),
            (lValue: Demand.max(3), rValue: Demand.max(5), result: Demand.none),
            (lValue: Demand.none, rValue: Demand.none, result: Demand.none),
            (lValue: Demand.none, rValue: Demand.max(3), result: Demand.none),
            (lValue: Demand.max(2), rValue: Demand.none, result: Demand.max(2))
        ]
    )
    func demand_substraction(lValue: Demand, rValue: Demand, result: Demand) {
        #expect((lValue - rValue) == result)
    }

    @Test(
        "Tests demand addition",
        arguments: [
            (lValue: Demand.unlimited, rValue: Demand.unlimited, result: Demand.unlimited),
            (lValue: Demand.unlimited, rValue: Demand.max(3), result: Demand.unlimited),
            (lValue: Demand.max(3), rValue: Demand.unlimited, result: Demand.unlimited),
            (lValue: Demand.max(3), rValue: Demand.max(3), result: Demand.max(6)),
            (lValue: Demand.none, rValue: Demand.none, result: Demand.none),
            (lValue: Demand.none, rValue: Demand.max(3), result: Demand.max(3)),
            (lValue: Demand.max(.max - 100), rValue: Demand.max(.max - 50), result: Demand.max(.max))
        ]
    )
    func demand_addition(lValue: Demand, rValue: Demand, result: Demand) {
        #expect((lValue + rValue) == result)
    }
}
