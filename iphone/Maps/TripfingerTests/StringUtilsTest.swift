import XCTest
import Firebase
@testable import Tripfinger

class StringUtilsTest: XCTestCase {
  
  func testSplitStringInParagraphs() {
    let string = "<p>One paragraph.</p>"
    let paragraphs = string.splitInParagraphs()
    XCTAssertEqual(1, paragraphs.count)
  }
}