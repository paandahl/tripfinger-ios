import UIKit
import XCTest
@testable import Tripfinger

class OnlineSearchTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
    continueAfterFailure = false
  }
  
  override func tearDown() {
    super.tearDown()
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

  func testOnlineSearchMultipleTerms() {
    let readyExpectation = expectationWithDescription("ready")
    
    OnlineSearch.search("boulevard dixmude") { searchResults in
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }
  
}