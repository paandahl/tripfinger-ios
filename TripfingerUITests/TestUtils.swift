import Foundation
import XCTest

extension XCUIElement {
  internal func scrollToElement(element: XCUIElement) {
    var i = 0
    while !element.hittable {
      if i < 3 {
        swipeUp()
      }
      else {
        swipeDown()
      }
      usleep(100)
      i += 1
    }
  }
}