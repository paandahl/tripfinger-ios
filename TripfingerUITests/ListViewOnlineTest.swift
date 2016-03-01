import Foundation
import XCTest

class ListViewOnlineTest: XCTestCase {
  
  let app = XCUIApplication()

  override func setUp() {
    super.setUp()
    continueAfterFailure = false
    app.launchArguments.append("TEST")
    app.launch()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testViewList() {
    tapWhenHittable(app.tables.staticTexts["Brunei"])
    app.tables.staticTexts["Attractions"].tap()
    waitUntilNotHittable(app.staticTexts["Loading..."])

    app.buttons["List"].tap()
   
    XCTAssertEqual(1, app.tables.cells.count)
  }
}