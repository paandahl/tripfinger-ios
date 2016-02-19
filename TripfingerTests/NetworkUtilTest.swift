import XCTest
@testable import Tripfinger

class NetworkUtilTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testEncodeUrl() {
    let url = "http://storage.googleapis.com/tripfinger-images/attraction-what-the-book%3F-1"
    let nsUrl = NetworkUtil.encodeTripfingerImageUrl(url)
    XCTAssertEqual(url, nsUrl.absoluteString)
  }
}