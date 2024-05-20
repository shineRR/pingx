import XCTest
@testable import pingx

// MARK: - IPv4AddressConverterTests

final class IPv4AddressConverterTests: XCTestCase {
    
    // MARK: Properties
    
    private var converter: IPv4AddressConverter!
    
    // MARK: Override
    
    override func setUp() {
        super.setUp()
        converter = IPv4AddressConverter()
    }
    
    override func tearDown() {
        super.tearDown()
        converter = nil
    }
    
    // MARK: Tests
    
    func testConverter_tuple() {
        let address: (UInt8, UInt8, UInt8, UInt8) = (8, 8, 8, 8)
        let expectedResult = IPv4Address(address: address)
        let actualResult = converter.convert(address: address)
    
        XCTAssertEqual(expectedResult, actualResult)
    }
    
    func testConverter_stringInvalidAddress() {
        let invalidAddresses: [String] = [
            "8",
            "8.8.8",
            "8.8:8.8",
            "8,8",
            "8,8,8,8",
            "8 8 8 8"
        ]
        
        for invalidAddress in invalidAddresses {
            do {
                let actualResult = try converter.convert(address: invalidAddress)
                XCTFail("\(actualResult)")
            } catch let error as IPAddressConverterError {
                XCTAssertEqual(error, .invalidAddress)
            } catch {}
        }
    }
    
    func testConverter_stringValidAddress() {
        let expectedResult = IPv4Address(address: (8, 8, 8, 8))
        do {
            let actualResult = try converter.convert(address: "8.8.8.8")
            XCTAssertEqual(expectedResult, actualResult)
        } catch {
            XCTFail("Expected to have an expectedResult")
        }
    }
    
}
