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
struct RequestTests {
    @Test(
        "When demand decreased, it sets correct new demand",
        arguments: [
            (initialDemand: Request.Demand.unlimited, expectedDemand: Request.Demand.unlimited),
            (initialDemand: Request.Demand.max(5), expectedDemand: Request.Demand.max(4)),
            (initialDemand: Request.Demand.max(1), expectedDemand: Request.Demand.none),
            (initialDemand: Request.Demand.none, expectedDemand: Request.Demand.none)
        ]
    )
    func demand_whenDemandDecreased_setsCorrectNewDemand(
        initialDemand: Request.Demand,
        expectedDemand: Request.Demand
    ) {
        var request = Request.sample(demand: initialDemand)
        
        request.decreaseDemand()

        #expect(request.demand == expectedDemand)
    }
    
    @Test(
        "When sequence number increased, it sets correct sequence number",
        arguments: [
            (initialSequenceNumber: UInt16.zero, expectedSequenceNumber: UInt16(1)),
            (initialSequenceNumber: UInt16(100), expectedSequenceNumber: UInt16(101)),
            (initialSequenceNumber: UInt16.max - 1, expectedSequenceNumber: UInt16.max),
            (initialSequenceNumber: UInt16.max, expectedSequenceNumber: .zero)
        ]
    )
    func demand_whenSequenceNumberIncreased_setsCorrectNewSequenceNumber(
        initialSequenceNumber: UInt16,
        expectedSequenceNumber: UInt16
    ) {
        var request = Request.sample(sequenceNumber: initialSequenceNumber)
        
        request.incrementSequenceNumber()

        #expect(request.sequenceNumber == expectedSequenceNumber)
    }
}
