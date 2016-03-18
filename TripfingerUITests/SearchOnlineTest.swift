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
  
  func testSearchForBruneiAndBangPae() {
    
    // region search from guide
    let app = XCUIApplication()
    app.navigationBars["Countries"].buttons["Search"].tap()
    
    var tripfingerSearchNavigationBar = app.navigationBars["Tripfinger.Search"]
    var searchField = tripfingerSearchNavigationBar.searchFields.element
    searchField.typeText("Brunei")

    let bruneiRow = app.tables.cells.containingType(.StaticText, identifier:"Country").staticTexts["Brunei"]
    expectationForPredicate(hittable, evaluatedWithObject: bruneiRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    bruneiRow.tap()
    
    let bandarRow = app.tables.staticTexts["Bandar"]
    expectationForPredicate(exists, evaluatedWithObject: bandarRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    
    // attraction search from guide
    app.navigationBars["Brunei"].buttons["Search"].tap()
    tripfingerSearchNavigationBar = app.navigationBars["Tripfinger.Search"]
    searchField = tripfingerSearchNavigationBar.searchFields.element
    waitUntilHittable(searchField)
    searchField.tap()
    searchField.typeText("Bang Pae")
    
    let bangPaeRow = app.tables.staticTexts["Bang Pae Waterfall"]
    tapWhenHittable(bangPaeRow)
    
    let backButton = app.navigationBars["Bang Pae Waterfall"].buttons["Back"]    
    tapWhenHittable(backButton)
    waitUntilExists(app.tables.staticTexts["Kata"])
    app.navigationBars["Phuket"].buttons["Search"].tap()
  }
}