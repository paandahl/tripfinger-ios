import XCTest
import RealmSwift
@testable import Tripfinger

class JsonParserServiceTest: XCTestCase {
  
  func testParseRegion() {
    let jsonPath = NSBundle.bundlePathForIdentifier("no.prebenludviksen.TripfingerTests") + "/thailand.json"
    let json = JSON(data: NSData(contentsOfFile: jsonPath)!)
    let thailand = JsonParserService.parseRegion(json)
    
    XCTAssertEqual(2, thailand.item().subRegions.count)
    XCTAssertEqual("Bangkok", thailand.item().subRegions[0].getName())
    XCTAssertEqual(Region.Category.CITY.rawValue, thailand.item().subRegions[0].item().category)
    XCTAssertEqual("Ko Samui", thailand.item().subRegions[1].getName())
    XCTAssertEqual(Region.Category.SUB_REGION.rawValue, thailand.item().subRegions[1].item().category)
  }
  
  func testParseDownloadedCountry() {
    let jsonPath = NSBundle.bundlePathForIdentifier("no.prebenludviksen.TripfingerTests") + "/brunei-download.json"
    print(jsonPath)
    let json = JSON(data: NSData(contentsOfFile: jsonPath)!)
    let brunei = JsonParserService.parseRegionTreeFromJson(json)

    XCTAssertEqual(2, brunei.item().simplePois.count)
  }
}