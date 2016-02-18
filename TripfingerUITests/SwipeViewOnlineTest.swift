import Foundation
import XCTest

class SwipeViewOnlineTest: XCTestCase {
  
  let exists = NSPredicate(format: "exists == 1")
  let hittable = NSPredicate(format: "hittable == 1")
  let notHittable = NSPredicate(format: "hittable == 0")
  var app: XCUIApplication!

  override func setUp() {
    super.setUp()
    continueAfterFailure = false
    app = XCUIApplication()
    app.launchArguments.append("TEST")
    app.launch()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testSwipeOnBangkokAndViewOnMap() {
    let thailandRow = app.tables.staticTexts["Thailand"]
    expectationForPredicate(exists, evaluatedWithObject: thailandRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    thailandRow.tap()

    let bangkokRow = app.tables.staticTexts["Bangkok"]
    expectationForPredicate(exists, evaluatedWithObject: bangkokRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    bangkokRow.tap()

    let silomRow = app.tables.staticTexts["Silom"]
    expectationForPredicate(exists, evaluatedWithObject: silomRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    app.navigationBars["Tripfinger.Root"].buttons["Swipe"].tap()
    
    let loadingLabel = app.staticTexts["Loading..."]
    expectationForPredicate(notHittable, evaluatedWithObject: loadingLabel, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    let frontCard = app.otherElements.elementMatchingType(.Other, identifier: "frontCard")
    frontCard.swipeRight()
    print("Accessibilityvalue: \(frontCard.value)")

    app.navigationBars["Tripfinger.Root"].buttons["Map"].tap()
    
    let mapView = app.otherElements.elementMatchingType(.Other, identifier: "mapView")
    expectationForPredicate(hittable, evaluatedWithObject: mapView, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    
    let likedElementDisplayed = NSPredicate(format: "value == '1'")
    expectationForPredicate(likedElementDisplayed, evaluatedWithObject: mapView, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
  }
  
  func testSwipeOnBetaCountry() {
    let bruneiRow = app.tables.staticTexts["Brunei"]
    expectationForPredicate(exists, evaluatedWithObject: bruneiRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    bruneiRow.tap()

    let exploreCountryRow = app.tables.staticTexts["Explore the country"]
    expectationForPredicate(exists, evaluatedWithObject: exploreCountryRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    app.navigationBars["Tripfinger.Root"].buttons["Swipe"].tap()

    let loadingLabel = app.staticTexts["Loading..."]
    expectationForPredicate(notHittable, evaluatedWithObject: loadingLabel, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    let frontCard = app.otherElements.elementMatchingType(.Other, identifier: "frontCard")
    let titleLabel = frontCard.staticTexts["Ulu Temburong National Park"]
    expectationForPredicate(hittable, evaluatedWithObject: titleLabel, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
  }
}