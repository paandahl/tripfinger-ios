import Foundation
import XCTest

class GuideViewOnlineTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
    continueAfterFailure = false
    let app = XCUIApplication()
    app.launchArguments.append("TEST")
    app.launch()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testNavigateThroughHierarchy() {
    let app = XCUIApplication()
    let exists = NSPredicate(format: "exists == 1")
    
    let thailandRow = app.tables.staticTexts["Thailand"]
    expectationForPredicate(exists, evaluatedWithObject: thailandRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    thailandRow.tap()
    
    let exploreCountryRow = app.tables.staticTexts["Explore the country"]
    expectationForPredicate(exists, evaluatedWithObject: exploreCountryRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    let bangkokRow = app.tables.staticTexts["Bangkok"]
    bangkokRow.tap()

    let silomRow = app.tables.staticTexts["Silom"]
    expectationForPredicate(exists, evaluatedWithObject: silomRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    silomRow.tap()

    var backButton = app.buttons["< Bangkok"]
    expectationForPredicate(exists, evaluatedWithObject: backButton, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    backButton.tap()

    backButton = app.buttons["< Thailand"]
    expectationForPredicate(exists, evaluatedWithObject: backButton, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    backButton.tap()

    backButton = app.buttons["< Overview"]
    expectationForPredicate(exists, evaluatedWithObject: backButton, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    backButton.tap()

    expectationForPredicate(exists, evaluatedWithObject: thailandRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    thailandRow.tap()
    
    expectationForPredicate(exists, evaluatedWithObject: exploreCountryRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    let koSamuiRow = app.tables.staticTexts["Ko Samui"]
    koSamuiRow.tap()

    let chawengRow = app.tables.staticTexts["Chaweng"]
    expectationForPredicate(exists, evaluatedWithObject: chawengRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    chawengRow.tap()
    
    backButton = app.buttons["< Ko Samui"]
    expectationForPredicate(exists, evaluatedWithObject: backButton, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    backButton.tap()

    backButton = app.buttons["< Thailand"]
    expectationForPredicate(exists, evaluatedWithObject: backButton, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    backButton.tap()
    
    backButton = app.buttons["< Overview"]
    expectationForPredicate(exists, evaluatedWithObject: backButton, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    backButton.tap()
    
    expectationForPredicate(exists, evaluatedWithObject: thailandRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)

  }
}