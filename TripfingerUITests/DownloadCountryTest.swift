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
    let exists = NSPredicate(format: "exists == 1")
    let hittable = NSPredicate(format: "hittable == 1")
    let notHittable = NSPredicate(format: "hittable == 0")
    
    let bruneiRow = app.tables.staticTexts["Brunei"]
    expectationForPredicate(exists, evaluatedWithObject: bruneiRow, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    bruneiRow.tap()
    
    var downloadButton = app.buttons["Download"]
    expectationForPredicate(exists, evaluatedWithObject: downloadButton, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    downloadButton.tap()
    
    let downloadLabel = app.staticTexts["Download Brunei:"]
    expectationForPredicate(exists, evaluatedWithObject: downloadLabel, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
    
    downloadButton = app.buttons["Download"]
    downloadButton.tap()

    downloadButton = app.buttons["Delete"]
    expectationForPredicate(hittable, evaluatedWithObject: downloadButton, handler: nil)
    waitForExpectationsWithTimeout(600, handler: nil)

  }
}