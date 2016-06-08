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
    
    
    let searchField = XCUIApplication().textFields["Search"]
    searchField.tap()
    searchField.typeText("Brunei")
    
    let bruneiRow = app.tables.cells.containingType(.StaticText, identifier:"Country 255").staticTexts["Brunei"]
    expectationForPredicate(hittable, evaluatedWithObject: bruneiRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    bruneiRow.tap()
    
    tapWhenHittable(app.tables.staticTexts["Bandar"])
    
    // attraction search from guide
    app.navigationBars["Bandar"].buttons["Search"].tap()
    
    searchField.typeText("Bang Pae")
    
    let bangPaeRow = app.tables.staticTexts["Bang Pae Waterfall"]
    tapWhenHittable(bangPaeRow)
    
    let backButton = app.navigationBars["Bang Pae Waterfall"].buttons["Back"]    
    tapWhenHittable(backButton)
    waitUntilExists(app.tables.staticTexts["Kata"])
    app.navigationBars["Phuket"].buttons["Search"].tap()
  }
}