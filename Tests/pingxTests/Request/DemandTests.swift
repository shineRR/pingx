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

import XCTest
@testable import pingx

final class DemandTests: XCTestCase {
    
    // MARK: Tests
    
    func testDemand_initialize() {
        var demand: Request.Demand
        
        demand = .none
        XCTAssertEqual(demand.max, .zero)
        
        demand = .unlimited
        XCTAssertNil(demand.max)
        
        demand = .max(3)
        XCTAssertEqual(demand.max, 3)
        
        expectFatalError(expectedMessage: "The value cannot be lower than 0.") {
            demand = .max(-1)
        }
    }
    
    func testDemand_subtraction() {
        let demandsA: [Request.Demand] = [.unlimited, .unlimited, .unlimited, .max(3), .max(2), .max(2), .max(3)]
        let demandsB: [Request.Demand] = [.unlimited, .none, .max(3), .max(2), .max(3), .max(2), .unlimited]
        let demandsC: [Request.Demand] = [.unlimited, .unlimited, .unlimited, .max(1), .none, .none, .none]
        
        for (index, (demandA, demandB)) in zip(demandsA, demandsB).enumerated() {
            XCTAssertEqual(demandA - demandB, demandsC[index])
        }
    }  
    
    func testDemand_addition() {
        let demandsA: [Request.Demand] = [.unlimited, .none, .unlimited, .max(1), .max(1), .none, .none]
        let demandsB: [Request.Demand] = [.unlimited, .unlimited, .none, .max(2), .none, .max(2), .none]
        let demandsC: [Request.Demand] = [.unlimited, .unlimited, .unlimited, .max(3), .max(1), .max(2), .none]
        
        for (index, (demandA, demandB)) in zip(demandsA, demandsB).enumerated() {
            XCTAssertEqual(demandA + demandB, demandsC[index])
        }
    }
}
