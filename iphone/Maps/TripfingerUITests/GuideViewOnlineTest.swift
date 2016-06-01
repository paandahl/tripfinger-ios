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
    
    tapWhenHittable(app.tables.staticTexts["Thailand"], parent: app.tables.element)
    
    sleep(2)
    let readMoreButton = app.buttons["Read more"]
    expectationForPredicate(hittable, evaluatedWithObject: readMoreButton, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    readMoreButton.tap()

    print(app.tables.staticTexts["Bangkok"].hittable)
    let understandRow = app.tables.staticTexts["Introduction"]
    scrollToElement(understandRow)
    understandRow.tap()
    
    let historyRow = app.tables.staticTexts["See"]
    expectationForPredicate(exists, evaluatedWithObject: historyRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    
    var backButton = app.navigationBars["Introduction"].buttons["Thailand"]
    backButton.tap()

    let chiangMaiRow = app.tables.staticTexts["Chiang Mai"]
    scrollToElement(chiangMaiRow)

    print("count4 \(app.tables.staticTexts.count)")
    
    let bangkokRow = app.tables.staticTexts["Bangkok"]
    scrollToElement(bangkokRow)
    bangkokRow.tap()
    
    print("TAPPED THE KOK")
    
    let silomRow = app.tables.staticTexts["Silom"]
    expectationForPredicate(exists, evaluatedWithObject: silomRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    scrollToElement(silomRow)
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

    tapWhenHittable(app.tables.staticTexts["Thailand"], parent: app.tables.element)
    
    expectationForPredicate(exists, evaluatedWithObject: chiangMaiRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    let koSamuiRow = app.tables.staticTexts["Ko Samui"]
    scrollToElement(koSamuiRow)
    koSamuiRow.tap()

    let chawengRow = app.tables.staticTexts["Chaweng"]
    expectationForPredicate(exists, evaluatedWithObject: chawengRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    scrollToElement(chawengRow)
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
    
    waitUntilExists(app.tables.staticTexts["Thailand"])
  }
}