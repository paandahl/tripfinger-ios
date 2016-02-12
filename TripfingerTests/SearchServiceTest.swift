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
    DownloadServiceTest.downloadBrunei { _ in
      print("offpacks1:")
      print(SKMapsService.sharedInstance().packagesManager.installedOfflineMapPackages)
      let searchService = SearchService(mapsObject: AppDelegate.session.mapsObject)
      searchService.search("ulu") { searchResults in
        for searchResult in searchResults {
          if searchResult.name == "Ulu Temburong National Park" {
            searchService.cancelSearch()
            exp.fulfill()
          }
        }
      }
    }
    waitForExpectationsWithTimeout(15) { error in XCTAssertNil(error, "Error") }
    DownloadServiceTest.removeBrunei()
    NetworkUtil.simulateOffline = false
    print("offpacks2:")
    print(SKMapsService.sharedInstance().packagesManager.installedOfflineMapPackages)
  }
  
  func testOfflineSearchForCity() {
    NetworkUtil.simulateOffline = true
    let exp = expectationWithDescription("ready")
    DownloadServiceTest.downloadBrunei { _ in
      print("offpacks3:")
      print(SKMapsService.sharedInstance().packagesManager.installedOfflineMapPackages)
      let searchService = SearchService(mapsObject: AppDelegate.session.mapsObject)
      searchService.search("bandar") { searchResults in
        for searchResult in searchResults {
          if searchResult.name == "Bandar Seri Begawan" {
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
