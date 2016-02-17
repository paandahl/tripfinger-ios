import UIKit
import XCTest
@testable import Tripfinger

class SearchServiceTest: XCTestCase {
  
  static var searchService: SearchService! // need to keep reference, in case delegate is called after we leave function scope
  
  override func setUp() {
    super.setUp()
    
    if SearchServiceTest.searchService == nil {
      SearchServiceTest.searchService = SearchService(mapsObject: AppDelegate.session.mapsObject)
      let location = CLLocation(latitude: 4.901522, longitude: 114.935343) // bandar seri begawan
      SearchServiceTest.searchService.setLocation(location, proximityInKm: 100.0)
    }
    
    DatabaseService.startTestMode()
    continueAfterFailure = false
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testOfflineSearchForAttraction() {
    NetworkUtil.simulateOffline = true
    let exp = expectationWithDescription("offlineSearchForAttraction")
    var fulfilled = false
    DownloadServiceTest.downloadBrunei { _ in
      print(SKMapsService.sharedInstance().packagesManager.installedOfflineMapPackages)
      SearchServiceTest.searchService.search("ulu") { searchResults in
        for searchResult in searchResults {
          if searchResult.name == "Ulu Temburong National Park" && !fulfilled {
            fulfilled = true
            print("Ulu Temburong was found.")
            SearchServiceTest.searchService.cancelSearch {
              exp.fulfill()              
            }
          }
        }
      }
    }
    waitForExpectationsWithTimeout(120) { error in XCTAssertNil(error, "Error") }
    DownloadServiceTest.removeBrunei()
    NetworkUtil.simulateOffline = false
    print(SKMapsService.sharedInstance().packagesManager.installedOfflineMapPackages)
  }
  
  func testOfflineSearchForCity() {
    NetworkUtil.simulateOffline = true
    let exp = expectationWithDescription("offlineSearchForCity")
    var fulfilled = false
    DownloadServiceTest.downloadBrunei { _ in
      print(SKMapsService.sharedInstance().packagesManager.installedOfflineMapPackages)
      SearchServiceTest.searchService.search("bandar") { searchResults in
        print("offlineSearch got \(searchResults.count) results")
        for searchResult in searchResults {
          if searchResult.name == "Bandar Seri Begawan" && !fulfilled {
            fulfilled = true
            SearchServiceTest.searchService.cancelSearch {
              exp.fulfill()
            }
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
    let exp = expectationWithDescription("offlineSearchForPoi")
    var fulfilled = false
    DownloadServiceTest.downloadBrunei { _ in
      print(SKMapsService.sharedInstance().packagesManager.installedOfflineMapPackages)
      SearchServiceTest.searchService.search("nyonya") { searchResults in
        for searchResult in searchResults {
          print("Found result: \(searchResult.name), \(searchResult.location)")
          print(fulfilled)
          if searchResult.name == "Nyonya Restaurant" {
            
            SyncManager.synchronized(self) {
              if !fulfilled {
                fulfilled = true
                print("fullfilled was set to true")
                SearchServiceTest.searchService.cancelSearch {
                  print("expfulfill")
                  exp.fulfill()
                }
              }
            }
            break
          }
        }
      }
    }
    waitForExpectationsWithTimeout(15) { error in XCTAssertNil(error, "Error") }
    print("removing brunei")
    DownloadServiceTest.removeBrunei()
    NetworkUtil.simulateOffline = false
  }
}
