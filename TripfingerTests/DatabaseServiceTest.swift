import XCTest
import BrightFutures
import Result
@testable import Tripfinger

class DatabaseServiceTest: XCTestCase {
  
  override func setUp() {
    DatabaseService.startTestMode()
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  class func insertBrunei(callback: (Region -> ())? = nil) {
    let jsonPath = NSBundle.bundlePathForIdentifier("no.prebenludviksen.TripfingerTests") + "/brunei-download.json"
    let json = JSON(data: NSData(contentsOfFile: jsonPath)!)
    let region = JsonParserService.parseRegionTreeFromJson(json)
    if let brunei = DatabaseService.getCountry("Brunei") {
      DatabaseService.deleteCountry(brunei.item().name)
    }
    try! DatabaseService.saveRegion(region, callback: callback)
  }
  
  func testSearch() {
    let exp = expectationWithDescription("ready")
    DatabaseServiceTest.insertBrunei { brunei in
      DatabaseService.search("ulu") { searchResults in
        XCTAssertEqual(1, searchResults.count)
        exp.fulfill()
      }
    }
    waitForExpectationsWithTimeout(15) { error in XCTAssertNil(error, "Error") }
  }
  
  func testDeleteRegion() {
    let exp = expectationWithDescription("ready")
    
    XCTAssertNil(DatabaseService.getCountry("Brunei"))
    DatabaseServiceTest.insertBrunei { region in
      var brunei = DatabaseService.getCountry("Brunei")
      XCTAssertNotNil(brunei)
      let attractions = DatabaseService.getAttractionsForRegion(brunei)
      XCTAssertEqual(1, attractions.count)
      let attractionId = attractions.first!.item().id
      
      DatabaseService.deleteCountry(brunei.item().name)

      brunei = DatabaseService.getCountry("Brunei")
      XCTAssertNil(brunei)
      let attraction = DatabaseService.getAttractionWithId(attractionId)
      XCTAssertNil(attraction)
      exp.fulfill()
    }
    
    waitForExpectationsWithTimeout(15) { error in XCTAssertNil(error, "Error") }
  }
}