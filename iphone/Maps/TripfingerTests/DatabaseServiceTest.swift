import XCTest
import BrightFutures
import Result
@testable import Tripfinger

class DatabaseServiceTest: XCTestCase {
  
  override func setUp() {
    DatabaseService.startTestMode()
    continueAfterFailure = false
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  class func insertBrunei(callback: (Region -> ())? = nil) {
    let jsonPath = NSBundle.bundlePathForIdentifier("com.tripfinger.TripfingerTests") + "/brunei-download.json"
    let json = JSON(data: NSData(contentsOfFile: jsonPath)!)
    let region = JsonParserService.parseRegionTreeFromJson(json)
    if let brunei = DatabaseService.getCountry("Brunei") {
      print("deletingBrunei")
      DatabaseService.deleteCountry(brunei.item().name)
    }
    try! DatabaseService.saveRegion(region, callback: callback)
  }
  
  func testSearch() {
    let exp = expectationWithDescription("ready")
    DatabaseServiceTest.insertBrunei { brunei in
      DatabaseService.search("ulu") { searchResults in
        for searchResult in searchResults {
          print("src: \(searchResult.name) \(searchResult.listingId)")
        }
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
      let attractions = DatabaseService.getListingsForRegion(brunei)
      print("count: \(attractions.count)")
      XCTAssertEqual(1, attractions.count)
      print(attractions.first!)
      let attractionId = attractions.first!.item().uuid
      
      DatabaseService.deleteCountry(brunei.item().name)

      brunei = DatabaseService.getCountry("Brunei")
      XCTAssertNil(brunei)
      let attraction = DatabaseService.getListingWithId(attractionId)
      XCTAssertNil(attraction)
      exp.fulfill()
    }
    
    waitForExpectationsWithTimeout(15) { error in XCTAssertNil(error, "Error") }
  }
  
  func testGetListingNotes() {
    
    // make sure it can handle quotes in id's
    DatabaseService.getListingNotes("attraction-tapgol-(\"pagoda\")-park-탑골공원")
  }
}