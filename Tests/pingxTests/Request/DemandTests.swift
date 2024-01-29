import XCTest
@testable import pingx

// MARK: - RequestTests

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
