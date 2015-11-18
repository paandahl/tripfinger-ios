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
    var fulfilled = false
    searchService.search("altitude", gradual: true) {
      searchResults in
      
      for searchResult in searchResults {
        if searchResult.name.containsString("Altitude Cent") {
          searchService.cancelSearch()
          if !fulfilled {
            fulfilled = true
            readyExpectation.fulfill()
          }
          break
        }
      }
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }
  
  func testSearchForUniqueStreet() {
    let startTime = NSDate()
    
    var readyExpectation = expectationWithDescription("ready")
    
    let searchService = SearchService()
    searchService.search("boulevard dixmude") {
      searchResults in
      
      XCTAssertEqual(1, searchResults.count)
      XCTAssertEqual("Brussels", searchResults[0].city)
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
    
    let endTime = NSDate()
    let executionTime = endTime.timeIntervalSinceDate(startTime)
    print("Time measured: \(executionTime * 1000.0)")
    
    readyExpectation = expectationWithDescription("ready")
    
    searchService.search("boulevard de dixmude") {
      searchResults in
      
      XCTAssertEqual(1, searchResults.count)
      XCTAssertEqual("Brussels", searchResults[0].city)
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
      
      XCTAssert(searchResults.count <= searchService.maxResults, "Too many search results")
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
