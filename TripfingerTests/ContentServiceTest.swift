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
    
    var contentService = ContentService()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testGetGuideTextsForGuideItem() {
        var guideItem = GuideItem()
        guideItem.id = Session().currentRegion
        var readyExpectation = expectationWithDescription("ready")
        
        contentService.getGuideTextsForGuideItem(guideItem) {
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
        
        waitForExpectationsWithTimeout(15, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func testGetContentForCurrentGuideItem() {
        var guideItem = GuideItem()
        guideItem.id = Session().currentRegion
        var readyExpectation = expectationWithDescription("ready")

        contentService.getContentForCurrentGuideItem() {
            guideItem, guideTexts, guideListings in
            
            XCTAssertEqual(12, guideTexts.count)
            XCTAssertEqual(17, guideListings.count)
            readyExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(15, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }

    func testGetCategoryDescription() {
        var guideItem = Region()
        guideItem.id = Session().currentRegion
        var readyExpectation = expectationWithDescription("ready")

        contentService.getDescriptionForCategory(Attraction.Types.TRANSPORTATION.rawValue, forRegion: guideItem) {
            guideText in
            
            XCTAssertNil(guideText.description)
            readyExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(15, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }

}
