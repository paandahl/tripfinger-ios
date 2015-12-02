import UIKit
import XCTest
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
  
  func testGetCategoryDescription() {
    let region = Region()
    region.listing = GuideListing()
    region.listing.item = GuideItem()
    region.listing.item.id = "region-brussels"
    let readyExpectation = expectationWithDescription("ready")
    
    ContentService.getDescriptionForCategory(Attraction.Category.TRANSPORTATION.rawValue, forRegion: region) {
      guideText in
      
      XCTAssertNil(guideText.item.content)
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(30, handler: { error in
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
}
