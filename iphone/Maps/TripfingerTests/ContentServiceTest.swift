import UIKit
import XCTest
import RealmSwift
@testable import Tripfinger

class ContentServiceTest: XCTestCase {
  
  let brusselsId = "9488f6bc-17c9-48d1-acf3-675a2cbf6948"
  
  override func setUp() {
    super.setUp()
    TripfingerAppDelegate.mode = .TEST
    continueAfterFailure = false
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testGetGuideTextsForGuideItem() {
    let guideItem = GuideItem()
    let readyExpectation = expectationWithDescription("ready")
    
    guideItem.uuid = brusselsId
    ContentService.getGuideTextsForGuideItem(guideItem, failure: {fatalError("EX1")}) {
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
    
    ContentService.getRegionWithId(brusselsId, failure: {fatalError("EX8")}) {
      region in
      
      XCTAssertEqual(12, region.listing.item.guideSections.count)
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }
  
  // check that category is filtered on also in offline mode
  func testGetCascadingListingsForRegion() {
    let exp = expectationWithDescription("ready")
    DatabaseServiceTest.insertBrunei { brunei in
      ContentService.getCascadingListingsForRegion(brunei.getId(), withCategory: Listing.Category.ATTRACTIONS.rawValue, failure: {fatalError("EX3")}) { listings in
        XCTAssertEqual(1, listings.count)
        XCTAssertEqual(1, brunei.item().subRegions.count)
        let bandar = brunei.item().subRegions[0]
        ContentService.getCascadingListingsForRegion(bandar.getId(), withCategory: Listing.Category.ATTRACTIONS.rawValue, failure: {fatalError("EX4")}) { listings in
          XCTAssertEqual(0, listings.count)
          XCTAssertEqual(1, bandar.item().subRegions.count)
          let malabau = bandar.item().subRegions[0]
          ContentService.getCascadingListingsForRegion(malabau.getId(), withCategory: Listing.Category.ATTRACTIONS.rawValue, failure: {fatalError("EX10")}) { listings in
            XCTAssertEqual(0, listings.count)
            exp.fulfill()
          }
        }
      }
    }
    waitForExpectationsWithTimeout(15) { error in XCTAssertNil(error, "Error") }
  }
}
