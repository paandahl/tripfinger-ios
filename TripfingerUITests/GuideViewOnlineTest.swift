import Foundation
import XCTest

class GuideViewOnlineTest: XCTestCase {
  
  let app = XCUIApplication()
  let exists = NSPredicate(format: "exists == 1")
  let hittable = NSPredicate(format: "hittable == 1")

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
    
    let thailandRow = app.tables.staticTexts["Thailand"]
    expectationForPredicate(exists, evaluatedWithObject: thailandRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    thailandRow.tap()
    
    sleep(2)
    let readMoreButton = app.buttons["Read more"]
    expectationForPredicate(hittable, evaluatedWithObject: readMoreButton, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    readMoreButton.tap()
    
    let understandRow = app.tables.staticTexts["Understand"]
    expectationForPredicate(exists, evaluatedWithObject: understandRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    understandRow.tap()
    
    let historyRow = app.tables.staticTexts["History"]
    expectationForPredicate(exists, evaluatedWithObject: historyRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    
    var backButton = app.navigationBars["Understand"].buttons["Thailand"]
    backButton.tap()

    let exploreCountryRow = app.tables.staticTexts["Explore the country"]
    expectationForPredicate(exists, evaluatedWithObject: exploreCountryRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)

    let bangkokRow = app.tables.staticTexts["Bangkok"]
    bangkokRow.tap()
    
    let silomRow = app.tables.staticTexts["Silom"]
    expectationForPredicate(exists, evaluatedWithObject: silomRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    silomRow.tap()

    backButton = app.navigationBars["Silom"].buttons["Bangkok"]
    expectationForPredicate(exists, evaluatedWithObject: backButton, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    backButton.tap()

    backButton = app.navigationBars["Bangkok"].buttons["Thailand"]
    expectationForPredicate(exists, evaluatedWithObject: backButton, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    backButton.tap()

    backButton = app.navigationBars["Thailand"].buttons["Countries"]
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
    
    backButton = app.navigationBars["Chaweng"].buttons["Ko Samui"]
    expectationForPredicate(exists, evaluatedWithObject: backButton, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    backButton.tap()

    backButton = app.navigationBars["Ko Samui"].buttons["Thailand"]
    expectationForPredicate(exists, evaluatedWithObject: backButton, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    backButton.tap()
    
    backButton = app.navigationBars["Thailand"].buttons["Countries"]
    expectationForPredicate(exists, evaluatedWithObject: backButton, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    backButton.tap()
    
    expectationForPredicate(exists, evaluatedWithObject: thailandRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)

  }
}