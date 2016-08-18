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
    
    
    let searchField = app.textFields["Search"]
    tapWhenHittable(searchField)
    searchField.typeText("Brunei")
    
    let bruneiRow = app.tables.cells.containingType(.StaticText, identifier:"Country 255").staticTexts["Brunei"]
    tapWhenHittable(bruneiRow)
    tapWhenHittable(app.tables.staticTexts["Bandar"])
    
    // attraction search from guide
    tapWhenHittable(app.navigationBars["Bandar"].buttons["Search"])
    
    sleep(1)
    tapWhenHittable(searchField)
    searchField.typeText("Bang Pae")
    
    let bangPaeRow = app.tables.staticTexts["Bang Pae Waterfall"]
    tapWhenHittable(bangPaeRow)
    
    let backButton = app.navigationBars["Bang Pae Waterfall"].buttons["Back"]    
    tapWhenHittable(backButton)
    waitUntilExists(app.tables.staticTexts["Kata"])
    tapWhenHittable(app.navigationBars["Phuket"].buttons["Search"])
    tapWhenHittable(app.buttons["Cancel"])
    
    // search for online object from map
    tapWhenHittable(app.navigationBars["Phuket"].buttons["Map"])
    tapWhenHittable(app.buttons["searchButton"])
    tapWhenHittable(searchField)
    sleep(1)
    searchField.typeText("Bang Pae")
    tapWhenHittable(bangPaeRow)
  }
}