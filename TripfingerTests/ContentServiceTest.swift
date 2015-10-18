//
//  ContentServiceTest.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 12/10/15.
//  Copyright (c) 2015 Preben Ludviksen. All rights reserved.
//

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
        var guideItem = GuideItem()
        var readyExpectation = expectationWithDescription("ready")

        getBrusselsId() {
            brusselsId in

            guideItem.id = brusselsId
            ContentService.getGuideTextsForGuideItem(guideItem) {
                guideTexts in
                
                println(guideTexts.count)
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
        var guideItem = GuideItem()
        var readyExpectation = expectationWithDescription("ready")

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
        var guideItem = Region()
        var readyExpectation = expectationWithDescription("ready")

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
