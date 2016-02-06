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
  
  
  
  func testOnlineSearchMultipleTerms() {
    let readyExpectation = expectationWithDescription("ready")
    
    OnlineSearch.search("boulevard dixmude") { searchResults in
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }
  
  
  func testUnspecificSearch() {
    let readyExpectation = expectationWithDescription("ready")
    
    let offlineSearch = OfflineSearch()
    offlineSearch.getStreets("di") {
      streets, finished in
      
      XCTAssert(streets.count <= offlineSearch.maxResults, "Too many search results")
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }
  
  func testOnlineSearch() {
    let readyExpectation = expectationWithDescription("ready")
    
    OnlineSearch.search("bel") {
      searchResults in
      
      XCTAssertEqual(7, searchResults.count)
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }
  
  func testLocking() {
    let readyExpectation = expectationWithDescription("ready")
    
    let lockQueue = dispatch_queue_create("com.test.LockQueue", nil)
    SyncManager.synchronized_async(lockQueue) {
      print("Entered first block")
      usleep(2 * 1000 * 1000)
      print("Exiting first block")
    }
    SyncManager.synchronized_async(lockQueue) {
      print("Entered second block")
      usleep(2 * 1000 * 1000)
      print("Exiting second block")
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }
  
  func testManualLocking() {
    let readyExpectation = expectationWithDescription("ready")
    
    SyncManager.run_async {
      SyncManager.get_lock(self)
      print("Entered first block")
      usleep(2 * 1000 * 1000)
      print("Exiting first block")
      try! SyncManager.release_lock(self)
    }

    SyncManager.run_async {
      SyncManager.get_lock(self)
      print("Entered second block")
      usleep(2 * 1000 * 1000)
      print("Exiting second block")
      try! SyncManager.release_lock(self)
      readyExpectation.fulfill()

    }

    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }
}
