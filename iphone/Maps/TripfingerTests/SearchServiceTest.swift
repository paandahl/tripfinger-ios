import UIKit
import XCTest
import CoreLocation
@testable import Tripfinger

class SearchServiceTest: XCTestCase {
  
  static var mapDownloaded = false
  static var searchService: SearchService! // need to keep reference, in case delegate is called after we leave function scope
 
  override class func tearDown() {
    print("removing brunei")
    DownloadServiceTest.removeBrunei()
  }
  
  override func setUp() {
    super.setUp()
    
    if SearchServiceTest.searchService == nil {
      SearchServiceTest.searchService = SearchService()
      let location = CLLocation(latitude: 4.901522, longitude: 114.935343) // bandar seri begawan
      SearchServiceTest.searchService.setLocation(location, proximityInKm: 100.0)
    }
    
    DatabaseService.startTestMode()
    continueAfterFailure = false
    
//    if !SearchServiceTest.mapDownloaded {
//      SearchServiceTest.mapDownloaded = true
//      let exp = expectationWithDescription("mapDownload")
//      SkobblerSearchTest.installMap("BN", exp: exp)
//      waitForExpectationsWithTimeout(240) { error in XCTAssertNil(error, "Error") }
//    }
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testOfflineSearchForListing() {
    NetworkUtil.simulateOffline = true
    let exp = expectationWithDescription("offlineSearchForListing")
    var fulfilled = false
    DatabaseServiceTest.insertBrunei { _ in
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
    NetworkUtil.simulateOffline = false
  }
  
  func testOfflineSearchForCity() {
    NetworkUtil.simulateOffline = true
    let exp = expectationWithDescription("offlineSearchForCity")
    var fulfilled = false
    DatabaseServiceTest.insertBrunei { _ in
      SearchServiceTest.searchService.search("bandar") { searchResults in
        print("offlineSearch got \(searchResults.count) results")
        for searchResult in searchResults {
          print(searchResult)
          if searchResult.name == "Bandar" && !fulfilled {
            print("got there")
            fulfilled = true
            SearchServiceTest.searchService.cancelSearch {
              print("but not here")
              exp.fulfill()
            }
            break
          }
        }
      }
    }
    waitForExpectationsWithTimeout(15) { error in XCTAssertNil(error, "Error") }
    NetworkUtil.simulateOffline = false
  }
}
