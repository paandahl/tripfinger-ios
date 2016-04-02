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
    tapWhenHittable(app.tables.staticTexts["Thailand"])
    tapWhenHittable(app.tables.staticTexts["Bangkok"])
    waitUntilExists(app.tables.staticTexts["Silom"])
    app.tables.staticTexts["Attractions"].tap()
    waitUntilNotHittable(app.staticTexts["Loading..."])

    let frontCard = app.otherElements.elementMatchingType(.Other, identifier: "frontCard")
    frontCard.swipeRight()

    app.navigationBars["Attractions"].buttons["Map"].tap()
    
//    let mapView = app.otherElements.elementMatchingType(.Other, identifier: "mapView")
//    waitUntilHittable(mapView)
//    
//    let likedElementDisplayed = NSPredicate(format: "value == '1'")
//    expectationForPredicate(likedElementDisplayed, evaluatedWithObject: mapView, handler: nil)
//    waitForExpectationsWithTimeout(60, handler: nil)
  }
  
  func testSwipeOnBetaCountry() {
    tapWhenHittable(app.tables.staticTexts["Brunei"])
    tapWhenHittable(app.tables.staticTexts["Attractions"])
    
    waitUntilNotHittable(app.staticTexts["Loading..."])
    let frontCard = app.otherElements.elementMatchingType(.Other, identifier: "frontCard")
    let titleLabel = frontCard.staticTexts["Ulu Temburong National Park"]
    waitUntilHittable(titleLabel)
  }
}