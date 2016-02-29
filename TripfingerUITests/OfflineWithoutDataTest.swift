import Foundation
import XCTest

class OfflineWithoutDataTest: XCTestCase {
  
  let exists = NSPredicate(format: "exists == 1")
  let hittable = NSPredicate(format: "hittable == 1")
  let notHittable = NSPredicate(format: "hittable == 0")
  var app: XCUIApplication!
  
  override func setUp() {
    super.setUp()
    continueAfterFailure = false
    app = XCUIApplication()
    app.launchArguments.append("TEST")
    app.launchArguments.append("OFFLINE")
    app.launch()
  }
  
  override func tearDown() {
    super.tearDown()
  }

  func testFlipThroughScreens() {
    let offlineMessage = app.tables.textViews["You are offline. Go online to view and download countries."]
    expectationForPredicate(hittable, evaluatedWithObject: offlineMessage, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
  }
}