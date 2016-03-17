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

  
  func testGetFullRegion() {
    let readyExpectation = expectationWithDescription("ready")
    
    ContentService.getFullRegionTree(brusselsId, failure: {fatalError("EX2")}) {
      region in
      
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(30, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }
  
  // check that category is filtered on also in offline mode
  func testGetCascadingListingsForRegion() {
    let exp = expectationWithDescription("ready")
    DatabaseServiceTest.insertBrunei { brunei in
      ContentService.getCascadingListingsForRegion(brunei, withCategory: Listing.Category.ATTRACTIONS, failure: {fatalError("EX3")}) { listings in
        XCTAssertEqual(1, listings.count)
        XCTAssertEqual(1, brunei.item().subRegions.count)
        let bandar = brunei.item().subRegions[0]
        ContentService.getCascadingListingsForRegion(bandar, withCategory: Listing.Category.ATTRACTIONS, failure: {fatalError("EX4")}) { listings in
          XCTAssertEqual(0, listings.count)
          exp.fulfill()
        }
      }
    }
    waitForExpectationsWithTimeout(15) { error in XCTAssertNil(error, "Error") }
  }
}
