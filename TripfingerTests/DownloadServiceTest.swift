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
    
  class func removeBrunei() {
    DatabaseService.deleteCountry("Brunei")
    SkobblerSearchTest.removeMap("BN")
  }
  
  func testGetAvailableMaps() {
    let readyExpectation = expectationWithDescription("ready")

    let mapVersionPromise = Promise<String, NoError>()
    DownloadService.getSKTMapsObject(mapVersionPromise.future).onSuccess {
      mapsObject in
      
      XCTAssertEqual(7, mapsObject.packagesForType(.Continent).count)
      readyExpectation.fulfill()
    }
    mapVersionPromise.success("")
    
    waitForExpectationsWithTimeout(15) { error in XCTAssertNil(error, "Error") }
  }
}
 