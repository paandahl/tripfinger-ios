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
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testContentService() {
        var guideItem = GuideItem()
        guideItem.id = 5629499534213120
        let readyExpectation = expectationWithDescription("ready")
        
        contentService.getGuideTextsForGuideItem(guideItem) {
            guideTexts in
            
            XCTAssertEqual(12, guideTexts.count)
            XCTAssertNotEqual("", guideTexts[0].description!, "")
            println("got guidetexts: \(guideTexts.count)")
            readyExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }
}
