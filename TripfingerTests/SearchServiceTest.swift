import UIKit
import XCTest
@testable import Tripfinger

class SearchServiceTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
    DatabaseService.startTestMode()
    continueAfterFailure = false
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testOfflineSearchForAttraction() {
    NetworkUtil.simulateOffline = true
    let exp = expectationWithDescription("ready")
    DownloadServiceTest.downloadBrunei { _ in
      let searchService = SearchService()
      searchService.search("ulu") { searchResults in
        XCTAssertEqual(1, searchResults.count)
        XCTAssertEqual("Ulu Temburong National Park", searchResults[0].name)
        searchService.cancelSearch()
        exp.fulfill()
      }      
    }
    waitForExpectationsWithTimeout(15) { error in XCTAssertNil(error, "Error") }
    DownloadServiceTest.removeBrunei()
    NetworkUtil.simulateOffline = false
  }
}
