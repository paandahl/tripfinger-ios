import UIKit
import XCTest
import Tripfinger

class ContentServiceTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func getBrusselsId(handler: Int -> ()) {
        ContentService.getRegions() {
            regions in
            
            handler(regions[0].id)
        }
    }

    func testGetGuideTextsForGuideItem() {
        let guideItem = GuideItem()
        let readyExpectation = expectationWithDescription("ready")

        
        
        getBrusselsId() {
            brusselsId in

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
        }
        
        waitForExpectationsWithTimeout(15, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func testGetRegionWithId() {
        let guideItem = GuideItem()
        let readyExpectation = expectationWithDescription("ready")

        getBrusselsId() {
            brusselsId in
            
            guideItem.id = brusselsId
            ContentService.getRegions() {
                regions in
                
                ContentService.getRegionWithId(regions[0].id) {
                    guideItem in
                    
                    XCTAssertEqual(12, guideItem.guideSections.count)
                    readyExpectation.fulfill()
                }
            }
        }

        waitForExpectationsWithTimeout(15, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }

    func testGetCategoryDescription() {
        let guideItem = Region()
        let readyExpectation = expectationWithDescription("ready")

        getBrusselsId() {
            brusselsId in
            
            guideItem.id = brusselsId
            ContentService.getDescriptionForCategory(Attraction.Category.TRANSPORTATION.rawValue, forRegion: guideItem) {
                guideText in
                
                XCTAssertNil(guideText.description)
                readyExpectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(15, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }

}
