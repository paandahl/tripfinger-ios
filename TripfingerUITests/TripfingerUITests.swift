import XCTest

class TripfingerUITests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    XCUIApplication().launch()
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testSearch() {
    let app = XCUIApplication()
    app.navigationBars["Tripfinger.Root"].buttons["Search"].tap()

    
    let searchSearchField = app.navigationBars["UISearch"].searchFields["Search"]
    searchSearchField.forceTapElement()
    searchSearchField.typeText("vient")
    
    
    let readyExpectation = expectationWithDescription("ready")
    waitForExpectationsWithTimeout(60, handler: nil)
  }
}

extension XCUIElement {
  func forceTapElement() {
    if self.hittable {
      self.tap()
    }
    else {
      let coordinate: XCUICoordinate = self.coordinateWithNormalizedOffset(CGVectorMake(0.0, 0.0))
      coordinate.tap()
    }
  }
}
