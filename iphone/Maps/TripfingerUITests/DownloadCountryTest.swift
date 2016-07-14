import Foundation
import XCTest

class DownloadCountryTest: XCTestCase {
  
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
  
  
  func testDownloadBrunei() {
    let app = XCUIApplication()
    
    let bruneiRow = app.tables.staticTexts["Brunei"]
    tapWhenHittable(bruneiRow, parent: app.tables.element)
    
    tapWhenHittable(app.buttons["Download"])
    tapWhenHittable(app.tables.staticTexts["Download guide"])
    app.buttons["Confirm"].tap()
    
    sleep(5)
    
    tapWhenHittable(app.tables.staticTexts["Guide content"])
    tapWhenHittable(app.sheets["Guide"].collectionViews.buttons["Delete guide content"])

    sleep(3)
    tapWhenHittable(app.navigationBars["Brunei"].buttons["Brunei"])
  }
}