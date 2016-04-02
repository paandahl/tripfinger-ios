  import Foundation
import XCTest

extension XCUIElement {
  internal func scrollToElement(element: XCUIElement) {
    var i = 0
    while !element.hittable {
      if i < 3 {
        swipeUp()
      } else {
        swipeDown()
      }
      i += 1
      usleep(100)
    }
  }
  
  internal func scrollToElementAndTap(element: XCUIElement) {
    scrollToElement(element)
    element.tap()
  }
}

extension XCTestCase {
  
  internal func scrollToElement(element: XCUIElement, container: XCUIElement) {
    waitUntilExists(element)
    container.scrollToElement(element)
  }
  
  internal func waitUntilExists(element: XCUIElement) {
    let exists = NSPredicate(format: "exists == 1")
    expectationForPredicate(exists, evaluatedWithObject: element, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
  }

  internal func waitUntilHittable(element: XCUIElement) {
    let hittable = NSPredicate(format: "hittable == 1")
    expectationForPredicate(hittable, evaluatedWithObject: element, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
  }

  internal func waitUntilNotHittable(element: XCUIElement) {
    let notHittable = NSPredicate(format: "hittable == 0")
    expectationForPredicate(notHittable, evaluatedWithObject: element, handler: nil)
    waitForExpectationsWithTimeout(60, handler: nil)
  }
  
  internal func tapWhenHittable(element: XCUIElement, parent: XCUIElement? = nil) {
    if let parent = parent {
      waitUntilExists(element)
      parent.scrollToElement(element)
    }
    waitUntilHittable(element)
    element.tap()
  }
}