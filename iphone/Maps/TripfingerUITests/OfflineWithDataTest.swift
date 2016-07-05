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
    
    sleep(1)
    XCTAssertEqual(1, app.tables.cells.count)
    
    tapWhenHittable(app.tables.staticTexts["Brunei"])
    
    sleep(2)
    tapWhenHittable(app.buttons["Read more"])
    tapWhenHittable(app.tables.staticTexts["History"])
    tapWhenHittable(app.navigationBars["History"].buttons["Brunei"])
    tapWhenHittable(app.tables.staticTexts["Food and drinks"])
    waitUntilExists(app.tables.staticTexts["Kaizen Sushi"])
    sleep(1)
    XCTAssertEqual(2, app.tables.cells.count)
    tapWhenHittable(app.navigationBars["Food and drinks"].buttons["Brunei"])
    tapWhenHittable(app.tables.staticTexts["Bandar"])
    tapWhenHittable(app.tables.staticTexts["Food and drinks"])
    tapWhenHittable(app.navigationBars["Food and drinks"].buttons["Bandar"])
    tapWhenHittable(app.navigationBars["Bandar"].buttons["Brunei"])
    tapWhenHittable(app.tables.staticTexts["Transportation"])
    tapWhenHittable(app.tables.staticTexts["Airports"])
    sleep(1)
    XCTAssertEqual(1, app.tables.cells.count)
    tapWhenHittable(app.tables.staticTexts["Brunei International Airport"])
    waitUntilExists(app.tables.textViews["info@airport.brunei"])
    let origin = app.coordinateWithNormalizedOffset(CGVector(dx: 0, dy: 0))
    let busLinkCoords = origin.coordinateWithOffset(CGVector(dx: 81.0, dy: 449.0))
    busLinkCoords.pressForDuration(0.2)
    tapWhenHittable(app.navigationBars["Bus station"].buttons["Back"])
    waitUntilExists(app.tables.textViews["info@airport.brunei"])
    
    tapWhenHittable(app.navigationBars["Brunei International Airport"].buttons["Back"])
    tapWhenHittable(app.navigationBars["Airports"].buttons["Transportation"])
    tapWhenHittable(app.navigationBars["Transportation"].buttons["Brunei"])
    
    // try to click a link
    scrollUp(2)
    let tableCoord = app.tables.element.coordinateWithNormalizedOffset(CGVector(dx: 0, dy: 0))
    var linkCoord = tableCoord.coordinateWithOffset(CGVector(dx: 65.0, dy: (118.0 + 64)))
    linkCoord.pressForDuration(0.2)
    tapWhenHittable(app.navigationBars["Bandar"].buttons["Brunei"])
    
    tapWhenHittable(app.tables.staticTexts["History"])
    linkCoord = tableCoord.coordinateWithOffset(CGVector(dx: 36.5, dy: (63.5 + 64)))
    linkCoord.pressForDuration(0.2)
    tapWhenHittable(app.navigationBars["Bandar"].buttons["History"])
    tapWhenHittable(app.navigationBars["History"].buttons["Brunei"])


    // do some swiping
    tapWhenHittable(app.tables.staticTexts["Attractions"])
    waitUntilNotHittable(app.staticTexts["Loading..."])
    let frontCard = app.otherElements.elementMatchingType(.Other, identifier: "frontCard")
    frontCard.swipeRight()
    app.navigationBars["Attractions"].buttons["Map"].tap()
    
//    let mapView = app.otherElements.elementMatchingType(.Other, identifier: "mapView")
//    waitUntilHittable(mapView)
    
//    let likedElementDisplayed = NSPredicate(format: "value == '1'")
//    expectationForPredicate(likedElementDisplayed, evaluatedWithObject: mapView, handler: nil)
//    waitForExpectationsWithTimeout(60, handler: nil)
  }
}