import UIKit
import XCTest
@testable import Tripfinger

class SearchServiceTest: XCTestCase {
  
  static let mapPackage = "test-belgium"
  
  override class func setUp() {
    
    if DownloadService.hasMapPackage(mapPackage) {
      SKMapsService.sharedInstance().packagesManager.deleteOfflineMapPackageNamed(mapPackage)
    }
    var mapPath: String!
    for bundle in NSBundle.allBundles() {
      if bundle.bundleIdentifier == "no.prebenludviksen.TripfingerTests" {
        mapPath = bundle.bundlePath
      }
    }
    
    SKMapsService.sharedInstance().packagesManager.addOfflineMapPackageNamed(SearchServiceTest.mapPackage, inContainingFolderPath: mapPath)
  }
  
  override class func tearDown() {
    SKMapsService.sharedInstance().packagesManager.deleteOfflineMapPackageNamed(SearchServiceTest.mapPackage)
  }
  
  override func setUp() {
    super.setUp()
    continueAfterFailure = false
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testGetCities() {
    var readyExpectation = expectationWithDescription("ready")
    
    let searchService = SearchService()
    searchService.getCities(forCountry: SearchServiceTest.mapPackage) {
      packageId, searchResults, nextCountryHandler in
      
      print("Found \(searchResults.count) cities.")
      XCTAssertEqual(3270, searchResults.count)
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
    
    readyExpectation = expectationWithDescription("ready")
    
    
    searchService.getCities() {
      packageId, searchResults, nextCountryHandler in
      
      if packageId == SearchServiceTest.mapPackage {
        XCTAssertEqual(3270, searchResults.count)
        readyExpectation.fulfill()
      }
      
      if let nextCountryHandler = nextCountryHandler {
        nextCountryHandler()
      }
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
    
  }
  
  func testSearchForAltitudeCent() {
    let readyExpectation = expectationWithDescription("ready")
    
    let searchService = SearchService()
    var fulfilled = false
    searchService.offlineSearch("altitude", regionId: SearchServiceTest.mapPackage, countryId: SearchServiceTest.mapPackage, gradual: true) {
      searchResults in
      
      for searchResult in searchResults {
        if searchResult.name.containsString("Altitude Cent") {
          if !fulfilled {
            fulfilled = true
            readyExpectation.fulfill()
          }
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
    let searchService = SearchService()

    searchService.offlineSearch("jfdsfs", regionId: SearchServiceTest.mapPackage, countryId: SearchServiceTest.mapPackage, gradual: true) {
      searchResults in
      
      print("got \(searchResults.count) search results.")
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }
  
  func testFireMultipleSearches() {
    let readyExpectation = expectationWithDescription("ready")
    let searchService = SearchService()
    
    
    searchService.offlineSearch("jfdsfs", regionId: SearchServiceTest.mapPackage, countryId: SearchServiceTest.mapPackage, gradual: true) {
      searchResults in
      
      print("got \(searchResults.count) search results.")
      readyExpectation.fulfill()
    }

    searchService.offlineSearch("br", regionId: SearchServiceTest.mapPackage, countryId: SearchServiceTest.mapPackage, gradual: true) {
      searchResults in
      
      print("got \(searchResults.count) search results.")
      readyExpectation.fulfill()
    }

    searchService.offlineSearch("bru", regionId: SearchServiceTest.mapPackage, countryId: SearchServiceTest.mapPackage, gradual: true) {
      searchResults in
      
      print("got \(searchResults.count) search results.")
      readyExpectation.fulfill()
    }

    searchService.offlineSearch("brussel", regionId: SearchServiceTest.mapPackage, countryId: SearchServiceTest.mapPackage, gradual: true) {
      searchResults in
      
      print("got \(searchResults.count) search results.")
      readyExpectation.fulfill()
    }

    searchService.offlineSearch("br", regionId: SearchServiceTest.mapPackage, countryId: SearchServiceTest.mapPackage, gradual: true) {
      searchResults in
      
      print("got \(searchResults.count) search results.")
      readyExpectation.fulfill()
    }

    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
    
  }
  
  func testOfflineSearchForUniqueStreet() {
    let startTime = NSDate()
    
    var readyExpectation = expectationWithDescription("ready")
    
    let searchService = SearchService()
    searchService.offlineSearch("boulevard dixmude", regionId: SearchServiceTest.mapPackage) {
      searchResults in
      
      XCTAssertEqual(1, searchResults.count)
      XCTAssertEqual("Brussels", searchResults[0].location)
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
    
    let endTime = NSDate()
    let executionTime = endTime.timeIntervalSinceDate(startTime)
    print("Time measured: \(executionTime * 1000.0)")
    
    readyExpectation = expectationWithDescription("ready")
    
    searchService.offlineSearch("boulevard de dixmude", regionId: SearchServiceTest.mapPackage) {
      searchResults in
      
      XCTAssertEqual(1, searchResults.count)
      XCTAssertEqual("Brussels", searchResults[0].location)
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }
  
  func testOnlineSearchMultipleTerms() {
    let readyExpectation = expectationWithDescription("ready")
    
    let searchService = SearchService()
    searchService.onlineSearch("boulevard dixmude", regionId: SearchServiceTest.mapPackage) {
      searchResults in
      
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }
  
  
  func testUnspecificSearch() {
    let readyExpectation = expectationWithDescription("ready")
    
    let searchService = SearchService()
    searchService.offlineSearch("di", regionId: SearchServiceTest.mapPackage) {
      searchResults in
      
      XCTAssert(searchResults.count <= searchService.maxResults, "Too many search results")
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }
  
  func testOnlineSearch() {
    let readyExpectation = expectationWithDescription("ready")
    
    let searchService = SearchService()
    searchService.onlineSearch("bel") {
      searchResults in
      
      XCTAssertEqual(7, searchResults.count)
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }
  
  func testLocking() {
    let readyExpectation = expectationWithDescription("ready")
    
    let lockQueue = dispatch_queue_create("com.test.LockQueue", nil)
    SyncManager.synchronized_async(lockQueue) {
      print("Entered first block")
      usleep(5 * 1000 * 1000)
      print("Exiting first block")
    }
    SyncManager.synchronized_async(lockQueue) {
      print("Entered second block")
      usleep(5 * 1000 * 1000)
      print("Exiting second block")
      readyExpectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }
  
  func testManualLocking() {
    let readyExpectation = expectationWithDescription("ready")
    
    SyncManager.run_async {
      SyncManager.get_lock(self)
      print("Entered first block")
      usleep(5 * 1000 * 1000)
      print("Exiting first block")
      try! SyncManager.release_lock(self)
    }

    SyncManager.run_async {
      SyncManager.get_lock(self)
      print("Entered second block")
      usleep(5 * 1000 * 1000)
      print("Exiting second block")
      try! SyncManager.release_lock(self)
      readyExpectation.fulfill()

    }

    waitForExpectationsWithTimeout(15, handler: { error in
      XCTAssertNil(error, "Error")
    })

  }
  
}
