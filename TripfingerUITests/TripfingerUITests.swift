//
//  TripfingerUITests.swift
//  TripfingerUITests
//
//  Created by Preben Ludviksen on 02/12/15.
//  Copyright © 2015 Preben Ludviksen. All rights reserved.
//

import XCTest

class TripfingerUITests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    XCUIApplication().launch()
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testOpenScreens() {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    let app = XCUIApplication()
    let belgiumRow = app.tables.staticTexts["Belgium"]
    let exists = NSPredicate(format: "exists == 1")
    let hittable = NSPredicate(format: "hittable == 1")
    expectationForPredicate(exists, evaluatedWithObject: belgiumRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    belgiumRow.tap()
    
    var textView = app.textViews.element
    expectationForPredicate(exists, evaluatedWithObject: textView, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    var text = textView.value as! String
    XCTAssertTrue(text.containsString("country in the Benelux"))
    
    let brusselsRow = app.tables.staticTexts["Brussels"]
    brusselsRow.tap()
    
    textView = app.textViews.element
    expectationForPredicate(exists, evaluatedWithObject: textView, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    text = textView.value as! String
    XCTAssertTrue(text.containsString("the capital of Belgium"))
    
    let exploreCityRow = app.tables.staticTexts["Explore the city"]
    exploreCityRow.tap()
    
    let atomiumLabel = app.staticTexts["Atomium"]
    expectationForPredicate(exists, evaluatedWithObject: atomiumLabel, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    
    
    atomiumLabel.swipeLeft()
    app.staticTexts["Brussels:"].tap()
    
    let allListingsRow = app.tables.staticTexts["All listings"]
    XCTAssertTrue(allListingsRow.exists)
    
    app.tables.staticTexts["Information"].tap()
    app.navigationBars["Filter"].buttons["Done"].tap()
    
    let noAttractionsLabel = app.staticTexts["No attractions to swipe."]
    expectationForPredicate(hittable, evaluatedWithObject: noAttractionsLabel, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
  }
  
  func testSearch() {
    let app = XCUIApplication()
    app.navigationBars["Tripfinger.Root"].buttons["Search"].tap()

    
    let searchSearchField = app.navigationBars["UISearch"].searchFields["Search"]
    searchSearchField.forceTapElement()
    searchSearchField.typeText("vient")
    
    
    let readyExpectation = expectationWithDescription("ready")
    waitForExpectationsWithTimeout(60, handler: nil)
  }
}

extension XCUIElement {
  func forceTapElement() {
    if self.hittable {
      self.tap()
    }
    else {
      let coordinate: XCUICoordinate = self.coordinateWithNormalizedOffset(CGVectorMake(0.0, 0.0))
      coordinate.tap()
    }
  }
}
