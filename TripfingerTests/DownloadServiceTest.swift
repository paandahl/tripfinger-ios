import XCTest
import BrightFutures
import Result
@testable import Tripfinger

class DownloadServiceTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
    
  class func removeBrunei() {
    DatabaseService.deleteCountry("Brunei")
    SkobblerSearchTest.removeMap("BN")
  }
  
  func testGetLocalPartOfFileUrl() {
    let url = NSURL(string: "file:///Users/prebenl/Library/Developer/CoreSimulator/Devices/6733284E-D5B9-4B76-A78B-F4239E5EC973/data/Containers/Data/Application/563A3160-559C-49BC-8868-E3B3DC53E595/Library/Thailand/attraction-wat-tham-ta-pan-bureau-of-monks-1")!
    let localPart = DownloadService.getLocalPartOfFileUrl(url)
    XCTAssertEqual("Thailand/attraction-wat-tham-ta-pan-bureau-of-monks-1", localPart)
  }
}
 