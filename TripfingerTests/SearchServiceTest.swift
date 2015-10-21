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
    
    func testGetCities() {
        let readyExpectation = expectationWithDescription("ready")
        
        let searchService = SearchService()
        searchService.getCities() {
            searchResults in
            
            print("Found \(searchResults.count) cities.")
            XCTAssertEqual(3270, searchResults.count)
            readyExpectation.fulfill()
        }

        waitForExpectationsWithTimeout(15, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func testSearchForAltitudeCent() {
        let readyExpectation = expectationWithDescription("ready")
        
        let searchService = SearchService()
        searchService.search("altitude") {
            searchResults in

            print("Results: \(searchResults)")
            var foundAltitudeCent = false
            for number in 0...2 {
                if searchResults[number].name.containsString("Altitude Cent") {
                    foundAltitudeCent = true
                    break
                }
            }
            XCTAssert(foundAltitudeCent)
            readyExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(15, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func testUnspecificSearch() {
        let readyExpectation = expectationWithDescription("ready")
        
        let searchService = SearchService()
        searchService.search("di") {
            searchResults in
            
            XCTAssert(searchResults.count <= 500, "Too many search results")
            readyExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(15, handler: { error in
            XCTAssertNil(error, "Error")
        })
        
    }
    
//    func testLocking() {
//        let readyExpectation = expectationWithDescription("ready")
//    
//        let lockQueue = dispatch_queue_create("com.test.LockQueue", nil)
//        SyncManager.run_async() {
//            dispatch_sync(lockQueue) {
//                print("Entered first block")
//                usleep(5 * 1000 * 1000)
//                print("Exiting first block")
//            }
//        }
//        SyncManager.run_async() {
//            dispatch_sync(lockQueue) {
//                print("Entered second block")
//                usleep(5 * 1000 * 1000)
//                print("Exiting second block")
//                readyExpectation.fulfill()
//            }
//        }
//
//        waitForExpectationsWithTimeout(15, handler: { error in
//            XCTAssertNil(error, "Error")
//        })
//    }
    
    
}
