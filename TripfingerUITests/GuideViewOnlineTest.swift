import Foundation
import XCTest

class GuideViewOnlineTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
    continueAfterFailure = false
    XCUIApplication().launch()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testNavigateThroughHierarchy() {
    let app = XCUIApplication()
    let exists = NSPredicate(format: "exists == 1")
    let hittable = NSPredicate(format: "hittable == 1")
    
    let asiaRow = app.tables.staticTexts["Asia"]
    expectationForPredicate(exists, evaluatedWithObject: asiaRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    asiaRow.tap()
    
    let uaeRow = app.tables.staticTexts["United Arab Emirates"] // choose an element that does not appear on entrance view
    expectationForPredicate(exists, evaluatedWithObject: uaeRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    var thailandRow = app.tables.staticTexts["Thailand"]
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

    backButton = app.buttons["< Asia"]
    expectationForPredicate(exists, evaluatedWithObject: backButton, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    backButton.tap()

    backButton = app.buttons["< Continents"]
    expectationForPredicate(exists, evaluatedWithObject: backButton, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    backButton.tap()

    expectationForPredicate(exists, evaluatedWithObject: asiaRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)

    // navigate directly from front page to country
    thailandRow = app.tables.staticTexts["Thailand"]
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
    
    backButton = app.buttons["< Asia"]
    expectationForPredicate(exists, evaluatedWithObject: backButton, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    backButton.tap()
    
    backButton = app.buttons["< Continents"]
    expectationForPredicate(exists, evaluatedWithObject: backButton, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    backButton.tap()
    
    expectationForPredicate(exists, evaluatedWithObject: asiaRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)

  }
}