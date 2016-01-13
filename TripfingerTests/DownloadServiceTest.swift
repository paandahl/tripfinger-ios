import XCTest
import BrightFutures
import Result
@testable import Tripfinger

class DownloadServiceTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testGetAvailableMaps() {
    let readyExpectation = expectationWithDescription("ready")

    DownloadService.getMapsAvailable().onSuccess {
      mapsObject in
      
      XCTAssertEqual(7, mapsObject.packagesForType(.Continent).count)
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })

  }
}
 