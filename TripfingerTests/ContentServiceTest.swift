import UIKit
import XCTest
import Tripfinger

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
                if guideText.name == "Understand" {
                    XCTAssertNotNil(guideText.description)
                    XCTAssertNotEqual("", guideText.description!)
                    foundUnderstand = true
                }
            }
            XCTAssertTrue(foundUnderstand)
            readyExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(15, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func testGetRegionWithId() {
        let readyExpectation = expectationWithDescription("ready")

        ContentService.getRegionWithId(brusselsId) {
            guideItem in

            XCTAssertEqual(12, guideItem.guideSections.count)
            readyExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(15, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }

    func testGetCategoryDescription() {
        let guideItem = Region()
        let readyExpectation = expectationWithDescription("ready")

        guideItem.id = brusselsId
        ContentService.getDescriptionForCategory(Attraction.Category.TRANSPORTATION.rawValue, forRegion: guideItem) {
            guideText in
            
            XCTAssertNil(guideText.description)
            readyExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(15, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }

}
