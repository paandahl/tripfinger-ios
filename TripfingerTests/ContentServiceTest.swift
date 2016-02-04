import UIKit
import XCTest
import RealmSwift
@testable import Tripfinger

class ContentServiceTest: XCTestCase {
  
  let brusselsId = "region-brussels"
  
  override func setUp() {
    super.setUp()
    continueAfterFailure = false
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testGetGuideTextsForGuideItem() {
    let guideItem = GuideItem()
    let readyExpectation = expectationWithDescription("ready")
    
    guideItem.id = brusselsId
    ContentService.getGuideTextsForGuideItem(guideItem) {
      guideTexts in
      
      print(guideTexts.count)
      XCTAssertEqual(12, guideTexts.count)
      
      var foundUnderstand = false
      for guideText in guideTexts {
        print(guideText.item.name)
        if guideText.item.name == "Understand" {
          XCTAssertNotNil(guideText.item.content)
          XCTAssertNotEqual("", guideText.item.content!)
          foundUnderstand = true
        }
      }
      XCTAssertTrue(foundUnderstand, "Did not find Understand-section")
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }
  
  func testGetRegionWithId() {
    let readyExpectation = expectationWithDescription("ready")
    
    ContentService.getRegionWithId(brusselsId) {
      region in
      
      XCTAssertEqual(12, region.listing.item.guideSections.count)
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }

  
  func testGetFullRegion() {
    let readyExpectation = expectationWithDescription("ready")
    
    ContentService.getFullRegionTree(brusselsId) {
      region in
      
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(30, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }
  
  func testParseRegion() {
    
    var jsonPath: String!
    for bundle in NSBundle.allBundles() {
      if bundle.bundleIdentifier == "no.prebenludviksen.TripfingerTests" {
        jsonPath = bundle.bundlePath + "/thailand.json"
      }
    }
    let jsonData = NSData(contentsOfFile: jsonPath)!
    let json = JSON(data: jsonData)
    let thailand = ContentService.parseRegion(json)
    
    XCTAssertEqual(2, thailand.item().subRegions.count)
    XCTAssertEqual("Bangkok", thailand.item().subRegions[0].getName())
    XCTAssertEqual(Region.Category.CITY.rawValue, thailand.item().subRegions[0].item().category)
    XCTAssertEqual("Ko Samui", thailand.item().subRegions[1].getName())
    // the category will be set to city until the real object is fetched, since we cannot know for sure 
    XCTAssertEqual(Region.Category.CITY.rawValue, thailand.item().subRegions[1].item().category)
  }
}
