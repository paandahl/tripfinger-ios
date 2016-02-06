import Foundation
import XCTest
@testable import Tripfinger

class OfflineSearchTest: XCTestCase {
  
  static let mapPackage = "test-belgium"
  
  override class func setUp() {
    
    if DownloadService.hasMapPackage(mapPackage) {
      SKMapsService.sharedInstance().packagesManager.deleteOfflineMapPackageNamed(mapPackage)
    }
    let mapPath = NSBundle.bundlePathForIdentifier("no.prebenludviksen.TripfingerTests")
    
    SKMapsService.sharedInstance().packagesManager.addOfflineMapPackageNamed(OfflineSearchTest.mapPackage, inContainingFolderPath: mapPath)
  }
  
  override class func tearDown() {
    SKMapsService.sharedInstance().packagesManager.deleteOfflineMapPackageNamed(OfflineSearchTest.mapPackage)
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
    let offlineSearch = OfflineSearch()
    let location = CLLocation(latitude: 50.847031, longitude: 4.353559)
    offlineSearch.getCitiesInProximityOf(location, proximityInKm: 50.0) {
      cities in
      
      XCTAssertEqual(952, cities.count)
      expectation.fulfill()
    }
    waitForExpectationsWithTimeout(15) { error in XCTAssertNil(error, "Error") }
  }

  func testGetCities() {
    var readyExpectation = expectationWithDescription("ready")
    
    let offlineSearch = OfflineSearch()
    offlineSearch.getCities(OfflineSearchTest.mapPackage) {
      cityResults in
      
      print("Found \(cityResults.count) cities.")
      XCTAssertEqual(3270, cityResults.count)
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
    
    readyExpectation = expectationWithDescription("ready")
    
    
    offlineSearch.getCities() {
      searchResults in
      
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
    
  }
  
  func testSearchForAltitudeCent() {
    let readyExpectation = expectationWithDescription("ready")
    
    let offlineSearch = OfflineSearch()
    var fulfilled = false
    offlineSearch.getStreets("altitude") {
      streets, finished in
    
      for street in streets {
        if street.name.containsString("Altitude Cent") {
          print("Found the bitch")
          if !fulfilled {
            fulfilled = true
            readyExpectation.fulfill()
          }
          offlineSearch.cancelSearch()
          break
        }
      }
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
    
  }
  
  func testOfflineSearchWithNoResults() {
    let readyExpectation = expectationWithDescription("ready")
    let offlineSearch = OfflineSearch()
    
    offlineSearch.getStreets("jfdsfs") {
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
    let offlineSearch = OfflineSearch()
    
    
    offlineSearch.getStreets("jfdsfs") { streets, finished in
      print("got \(streets.count) search results.")
      offlineSearch.cancelSearch()
      readyExpectation.fulfill()
    }
    
    offlineSearch.getStreets("br") { streets, finished in
      print("got \(streets.count) search results.")
      offlineSearch.cancelSearch()
      readyExpectation.fulfill()
    }
    
    offlineSearch.getStreets("bru") { streets, finished in
      print("got \(streets.count) search results.")
      offlineSearch.cancelSearch()
      readyExpectation.fulfill()
    }
    
    offlineSearch.getStreets("brussel") { streets, finished in
      print("got \(streets.count) search results.")
      offlineSearch.cancelSearch()
      readyExpectation.fulfill()
    }
    
    offlineSearch.getStreets("br") { streets, finished in
      print("got \(streets.count) search results.")
      offlineSearch.cancelSearch()
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Expectation timed out.")
    })    
  }
  
  func testOfflineSearchForUniqueStreet() {
    let startTime = NSDate()
    
    var readyExpectation = expectationWithDescription("ready")
    
    let offlineSearch = OfflineSearch()
    offlineSearch.getStreetsBulk("boulevard dixmude") {
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
    
    offlineSearch.getStreetsBulk("boulevard de dixmude") {
      streets in
      
      XCTAssertEqual(1, streets.count)
      XCTAssertEqual("Brussels", streets[0].location)
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }

}