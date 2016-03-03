import Foundation
import XCTest

class OfflineWithDataTest: XCTestCase {
  
  let app = XCUIApplication()
  
  override func setUp() {
    super.setUp()
    continueAfterFailure = false
    app.launchArguments.append("TEST")
    app.launchArguments.append("OFFLINEMAP")
    app.launch()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testNavigateHierarchy() {
    let table = app.tables.element
    let bruneiDownloaded = NSPredicate(format: "value == 'bruneiReady'")
    expectationForPredicate(bruneiDownloaded, evaluatedWithObject: table, handler: nil)
    waitForExpectationsWithTimeout(1200, handler: nil)
    
    tapWhenHittable(app.tables.staticTexts["Brunei"])
    
    sleep(2)
    tapWhenHittable(app.buttons["Read more"])
    tapWhenHittable(app.tables.staticTexts["History"])
    tapWhenHittable(app.navigationBars["History"].buttons["Brunei"])
    tapWhenHittable(app.tables.staticTexts["Attractions"])
    tapWhenHittable(app.navigationBars["Attractions"].buttons["Brunei"])
    tapWhenHittable(app.tables.staticTexts["Food and drinks"])
    waitUntilExists(app.tables.staticTexts["Kaizen Sushi"])
    XCTAssertEqual(2, app.tables.cells.count)
  }
}