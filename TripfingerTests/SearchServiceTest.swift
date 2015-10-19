import UIKit
import XCTest
@testable import Tripfinger

class SearchServiceTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSearch() {
        let readyExpectation = expectationWithDescription("ready")
        
        let searchService = SearchService()
        searchService.getCities() {
            searchResults in
            
            print("Found \(searchResults.count) cities.")
            for city in searchResults {
                print("\(city.name) - \(city.identifier)")

                searchService.getStreetsForCity(city.identifier) {
                    streets in
                    
                    for street in streets {
                        print("\(street.name) - \(street.type.rawValue) - \(street.mainCategory.rawValue)")
                    }
                    print("Found \(streets.count) streets.")
                    readyExpectation.fulfill()
                }
            }
        }

        waitForExpectationsWithTimeout(15, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }
    
}
