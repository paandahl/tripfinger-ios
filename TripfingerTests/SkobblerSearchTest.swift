import Foundation
import XCTest
@testable import Tripfinger

class SkobblerSearchTest: XCTestCase {
  
  static let belgiumMapPackage = "BE"
  
  override class func setUp() {
    installMap(belgiumMapPackage)
  }
  
  override class func tearDown() {
    print("removing belgium map")
    removeMap(belgiumMapPackage)
  }
  
  class func installMap(mapPackage: String) {
    
    if DownloadService.hasMapPackage(mapPackage) {
      SKMapsService.sharedInstance().packagesManager.deleteOfflineMapPackageNamed(mapPackage)
    }
    let mapPath = NSBundle.bundlePathForIdentifier("no.prebenludviksen.TripfingerTests")
    print(mapPath)

    // first make copies, since we might need to install from several tests, and Skobbler automatically deletes the added files
    NSData(contentsOfFile: "\(mapPath)/\(mapPackage)-test.ngi")?.writeToFile("\(mapPath)/\(mapPackage).ngi", atomically: true)
    NSData(contentsOfFile: "\(mapPath)/\(mapPackage)-test.ngi.dat")?.writeToFile("\(mapPath)/\(mapPackage).ngi.dat", atomically: true)
    NSData(contentsOfFile: "\(mapPath)/\(mapPackage)-test.skm")?.writeToFile("\(mapPath)/\(mapPackage).skm", atomically: true)
    NSData(contentsOfFile: "\(mapPath)/\(mapPackage)-test.txg")?.writeToFile("\(mapPath)/\(mapPackage).txg", atomically: true)
    
    SKMapsService.sharedInstance().packagesManager.addOfflineMapPackageNamed(mapPackage, inContainingFolderPath: mapPath)
  }
  
  class func removeMap(mapPackage: String) {
    let result = SKMapsService.sharedInstance().packagesManager.deleteOfflineMapPackageNamed(mapPackage)
    print("deletemap: \(mapPackage) - \(result)")
    let packs = SKMapsService.sharedInstance().packagesManager.installedOfflineMapPackages as! [SKMapPackage]
    for pack in packs {
      print("present: \(pack.name)")
      if pack.name == mapPackage {
        print("FUCK, it's still there: \(mapPackage)")
      }
    }
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
    let skobblerSearch = SkobblerSearch(mapsObject: AppDelegate.session.mapsObject)
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
    
    let skobblerSearch = SkobblerSearch(mapsObject: AppDelegate.session.mapsObject)
    skobblerSearch.getCities(packageCode: SkobblerSearchTest.belgiumMapPackage) {
      cityResults in
      
      print("Found \(cityResults.count) cities.")
      XCTAssertEqual(3270, cityResults.count)
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15) { error in XCTAssertNil(error, "Error") }
    XCTAssertFalse(skobblerSearch.isRunning())
    
    readyExpectation = expectationWithDescription("ready")
    
    
    skobblerSearch.getCities() {
      searchResults in
      
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15) { error in XCTAssertNil(error, "Error") }
  }
  
  func testSearchForAltitudeCent() {
    let readyExpectation = expectationWithDescription("ready")
    
    let skobblerSearch = SkobblerSearch(mapsObject: AppDelegate.session.mapsObject)
    var fulfilled = false
    skobblerSearch.getStreets("altitude") {
      streets, finished in
    
      for street in streets {
        if street.name.containsString("Altitude Cent") {
          print("Found the bitch")
          if !fulfilled {
            fulfilled = true
            skobblerSearch.cancelSearch {
              readyExpectation.fulfill()
            }
          }
          break
        }
      }
    }
    
    waitForExpectationsWithTimeout(15) { error in XCTAssertNil(error, "Error") }
  }
  
  func testSkobblerSearchWithNoResults() {
    let readyExpectation = expectationWithDescription("ready")
    let skobblerSearch = SkobblerSearch(mapsObject: AppDelegate.session.mapsObject)

    var resultsCounter = 0
    skobblerSearch.getStreets("jfdsfs", packageCode: "BE") {
      streets, finished in
      
      resultsCounter += streets.count
      if finished {
        print("got \(resultsCounter) search results.")
        readyExpectation.fulfill()
      }
    }
    
    waitForExpectationsWithTimeout(120) { error in XCTAssertNil(error, "Error") }
    XCTAssertFalse(skobblerSearch.isRunning())
  }
  
  func testFireMultipleSearches() {
    let readyExpectation = expectationWithDescription("multipleSearches")
    let skobblerSearch = SkobblerSearch(mapsObject: AppDelegate.session.mapsObject)
    
    var fulfilled = false
    
    skobblerSearch.getStreets("jfdsfs") { streets, finished in
      print("got \(streets.count) search results.")
      if !fulfilled {
        fulfilled = true
        skobblerSearch.cancelSearch {
          readyExpectation.fulfill()
        }
      }
    }
    
    skobblerSearch.getStreets("br") { streets, finished in
      print("got \(streets.count) search results.")
      if !fulfilled {
        fulfilled = true
        skobblerSearch.cancelSearch {
          readyExpectation.fulfill()
        }
      }
    }
    
    skobblerSearch.getStreets("bru") { streets, finished in
      print("got \(streets.count) search results.")
      if !fulfilled {
        fulfilled = true
        skobblerSearch.cancelSearch {
          readyExpectation.fulfill()
        }
      }
    }
    
    skobblerSearch.getStreets("brussel") { streets, finished in
      print("got \(streets.count) search results.")
      if !fulfilled {
        fulfilled = true
        skobblerSearch.cancelSearch {
          readyExpectation.fulfill()
        }
      }
    }
    
    skobblerSearch.getStreets("br") { streets, finished in
      print("got \(streets.count) search results.")
      if !fulfilled {
        fulfilled = true
        skobblerSearch.cancelSearch {
          readyExpectation.fulfill()
        }
      }
    }
    
    waitForExpectationsWithTimeout(120, handler: { error in
      XCTAssertNil(error, "Expectation timed out.")
    })    
  }
  
  func testSkobblerSearchForUniqueStreet() {
    let startTime = NSDate()
    
    var readyExpectation = expectationWithDescription("ready")
    
    let skobblerSearch = SkobblerSearch(mapsObject: AppDelegate.session.mapsObject)
    skobblerSearch.getStreetsBulk("boulevard dixmude", packageCode: "BE") {
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
    
    skobblerSearch.getStreetsBulk("boulevard de dixmude", packageCode: "BE") {
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
    
    let skobblerSearch = SkobblerSearch(mapsObject: AppDelegate.session.mapsObject)
    skobblerSearch.getStreets("di") {
      streets, finished in
      
      XCTAssert(streets.count <= skobblerSearch.maxResults, "Too many search results: \(streets.count)")
      skobblerSearch.cancelSearch {
        readyExpectation.fulfill()        
      }
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }
}