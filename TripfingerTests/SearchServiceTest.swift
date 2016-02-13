import UIKit
import XCTest
@testable import Tripfinger

class SearchServiceTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
    DatabaseService.startTestMode()
    continueAfterFailure = false
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testOfflineSearchForAttraction() {
    NetworkUtil.simulateOffline = true
    let exp = expectationWithDescription("ready")
    var fulfilled = false
    DownloadServiceTest.downloadBrunei { _ in
      print(SKMapsService.sharedInstance().packagesManager.installedOfflineMapPackages)
      let searchService = SearchService(mapsObject: AppDelegate.session.mapsObject)
      searchService.search("ulu") { searchResults in
        for searchResult in searchResults {
          if searchResult.name == "Ulu Temburong National Park" && !fulfilled {
            fulfilled = true
            print("Ulu Temburong was found.")
            searchService.cancelSearch()
            exp.fulfill()
          }
        }
      }
    }
    waitForExpectationsWithTimeout(15) { error in XCTAssertNil(error, "Error") }
    DownloadServiceTest.removeBrunei()
    NetworkUtil.simulateOffline = false
    print(SKMapsService.sharedInstance().packagesManager.installedOfflineMapPackages)
  }
  
  func testOfflineSearchForCity() {
    NetworkUtil.simulateOffline = true
    let exp = expectationWithDescription("ready")
    var fulfilled = false
    DownloadServiceTest.downloadBrunei { _ in
      print(SKMapsService.sharedInstance().packagesManager.installedOfflineMapPackages)
      let searchService = SearchService(mapsObject: AppDelegate.session.mapsObject)
      searchService.search("bandar") { searchResults in
        for searchResult in searchResults {
          if searchResult.name == "Bandar Seri Begawan" && !fulfilled {
            fulfilled = true
            searchService.cancelSearch()
            exp.fulfill()
            break
          }
        }
      }
    }
    waitForExpectationsWithTimeout(15) { error in XCTAssertNil(error, "Error") }
    DownloadServiceTest.removeBrunei()
    NetworkUtil.simulateOffline = false
  }
  
  func testOfflineSearchForPoi() {
    NetworkUtil.simulateOffline = true
    let exp = expectationWithDescription("ready")
    DownloadServiceTest.downloadBrunei { _ in
      print(SKMapsService.sharedInstance().packagesManager.installedOfflineMapPackages)
      let searchService = SearchService(mapsObject: AppDelegate.session.mapsObject)
      searchService.search("nyonya") { searchResults in
        for searchResult in searchResults {
          print("Found result: \(searchResult.name), \(searchResult.location)")
          if searchResult.name == "Nyonya Restaurant" {
            searchService.cancelSearch()
            exp.fulfill()
            break
          }
        }
      }
    }
    waitForExpectationsWithTimeout(15) { error in XCTAssertNil(error, "Error") }
    DownloadServiceTest.removeBrunei()
    NetworkUtil.simulateOffline = false
  }
}
