import Foundation
import XCTest
@testable import Tripfinger

class SkobblerSearchTest: XCTestCase {
  
  static let mapPackage = "test-belgium"
  
  override class func setUp() {
    installMap(mapPackage)
  }
  
  override class func tearDown() {
    removeMap(mapPackage)
  }
  
  class func installMap(mapPackage: String) {
    if DownloadService.hasMapPackage(mapPackage) {
      SKMapsService.sharedInstance().packagesManager.deleteOfflineMapPackageNamed(mapPackage)
    }
    let mapPath = NSBundle.bundlePathForIdentifier("no.prebenludviksen.TripfingerTests")
    
    SKMapsService.sharedInstance().packagesManager.addOfflineMapPackageNamed(mapPackage, inContainingFolderPath: mapPath)
  }
  
  class func removeMap(mapPackage: String) {
    SKMapsService.sharedInstance().packagesManager.deleteOfflineMapPackageNamed(mapPackage)
  }
  
  override func setUp() {
    super.setUp()
    continueAfterFailure = false
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testGetCitiesInProximity() {    
    let expectation = expectationWithDescription("ready")
    let skobblerSearch = SkobblerSearch()
    let location = CLLocation(latitude: 50.847031, longitude: 4.353559)
    skobblerSearch.getCitiesInProximityOf(location, proximityInKm: 30) {
      cities in
      
      XCTAssertEqual(365, cities.count)
      expectation.fulfill()
    }
    waitForExpectationsWithTimeout(15) { error in XCTAssertNil(error, "Error") }
  }

  func testGetCities() {
    var readyExpectation = expectationWithDescription("ready")
    
    let skobblerSearch = SkobblerSearch()
    skobblerSearch.getCities(SkobblerSearchTest.mapPackage) {
      cityResults in
      
      print("Found \(cityResults.count) cities.")
      XCTAssertEqual(3270, cityResults.count)
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
    
    readyExpectation = expectationWithDescription("ready")
    
    
    skobblerSearch.getCities() {
      searchResults in
      
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
    
  }
  
  func testSearchForAltitudeCent() {
    let readyExpectation = expectationWithDescription("ready")
    
    let skobblerSearch = SkobblerSearch()
    var fulfilled = false
    skobblerSearch.getStreets("altitude") {
      streets, finished in
    
      for street in streets {
        if street.name.containsString("Altitude Cent") {
          print("Found the bitch")
          if !fulfilled {
            fulfilled = true
            readyExpectation.fulfill()
          }
          skobblerSearch.cancelSearch()
          break
        }
      }
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
    
  }
  
  func testSkobblerSearchWithNoResults() {
    let readyExpectation = expectationWithDescription("ready")
    let skobblerSearch = SkobblerSearch()
    
    skobblerSearch.getStreets("jfdsfs") {
      streets, finished in
      
      print("got \(streets.count) search results.")
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }
  
  func testFireMultipleSearches() {
    let readyExpectation = expectationWithDescription("ready")
    let skobblerSearch = SkobblerSearch()
    
    
    skobblerSearch.getStreets("jfdsfs") { streets, finished in
      print("got \(streets.count) search results.")
      skobblerSearch.cancelSearch()
      readyExpectation.fulfill()
    }
    
    skobblerSearch.getStreets("br") { streets, finished in
      print("got \(streets.count) search results.")
      skobblerSearch.cancelSearch()
      readyExpectation.fulfill()
    }
    
    skobblerSearch.getStreets("bru") { streets, finished in
      print("got \(streets.count) search results.")
      skobblerSearch.cancelSearch()
      readyExpectation.fulfill()
    }
    
    skobblerSearch.getStreets("brussel") { streets, finished in
      print("got \(streets.count) search results.")
      skobblerSearch.cancelSearch()
      readyExpectation.fulfill()
    }
    
    skobblerSearch.getStreets("br") { streets, finished in
      print("got \(streets.count) search results.")
      skobblerSearch.cancelSearch()
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Expectation timed out.")
    })    
  }
  
  func testSkobblerSearchForUniqueStreet() {
    let startTime = NSDate()
    
    var readyExpectation = expectationWithDescription("ready")
    
    let skobblerSearch = SkobblerSearch()
    skobblerSearch.getStreetsBulk("boulevard dixmude") {
      streets in
      
      XCTAssertEqual(1, streets.count, "Search result was not 1")
      XCTAssertEqual("Brussels", streets[0].location, "Location was not set to brussels")
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
    
    let endTime = NSDate()
    let executionTime = endTime.timeIntervalSinceDate(startTime)
    print("Time measured: \(executionTime * 1000.0)")
    
    readyExpectation = expectationWithDescription("ready")
    
    skobblerSearch.getStreetsBulk("boulevard de dixmude") {
      streets in
      
      XCTAssertEqual(1, streets.count)
      XCTAssertEqual("Brussels", streets[0].location)
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }

  func testUnspecificSearch() {
    let readyExpectation = expectationWithDescription("ready")
    
    let skobblerSearch = SkobblerSearch()
    skobblerSearch.getStreets("di") {
      streets, finished in
      
      XCTAssert(streets.count <= skobblerSearch.maxResults, "Too many search results")
      skobblerSearch.cancelSearch()
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }
}