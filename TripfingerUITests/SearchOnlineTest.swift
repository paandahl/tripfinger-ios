import Foundation
import XCTest

class SearchOnlineTest: XCTestCase {
  
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
  
  func testSearchForBrunei() {
    
    let app = XCUIApplication()
    app.navigationBars["Countries"].buttons["Search"].tap()
    
    let tripfingerSearchNavigationBar = app.navigationBars["Tripfinger.Search"]
    let searchField = tripfingerSearchNavigationBar.searchFields.element
    searchField.typeText("Brunei")

    let bruneiRow = app.tables.cells.containingType(.StaticText, identifier:"Country").staticTexts["Brunei"]
    expectationForPredicate(hittable, evaluatedWithObject: bruneiRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    bruneiRow.tap()
    
    let exploreCountryRow = app.tables.staticTexts["Explore the country"]
    expectationForPredicate(exists, evaluatedWithObject: exploreCountryRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
  }
}