  import Foundation
import XCTest

extension XCUIElement {
//  internal func scrollToElement(element: XCUIElement) {
//    var i = 0
//    while !element.hittable {
//      if i < 3 {
//        swipeUp()
//      } else {
//        swipeDown()
//      }
//      i += 1
//      usleep(100)
//    }
//  }
//  
//  internal func scrollToElementAndTap(element: XCUIElement) {
//    scrollToElement(element)
//    element.tap()
//  }
}

extension XCTestCase {
  
  func mainWindow() -> XCUIElement {
    return XCUIApplication().windows.elementBoundByIndex(0)
  }

  func scrollDown( times: Int = 1) {
    let topScreenPoint = mainWindow().coordinateWithNormalizedOffset(CGVector(dx: 0.5, dy: 0.10))
    let bottomScreenPoint = mainWindow().coordinateWithNormalizedOffset(CGVector(dx: 0.5, dy: 0.90))
    for _ in 0..<times {
      bottomScreenPoint.pressForDuration(0, thenDragToCoordinate: topScreenPoint)
    }
  }
  
  func scrollUp(times: Int = 1) {
    let topScreenPoint = mainWindow().coordinateWithNormalizedOffset(CGVector(dx: 0.5, dy: 0.10))
    let bottomScreenPoint = mainWindow().coordinateWithNormalizedOffset(CGVector(dx: 0.5, dy: 0.90))
    for _ in 0..<times {
      topScreenPoint.pressForDuration(0, thenDragToCoordinate: bottomScreenPoint)
    }
  }
  
  func elementIsWithinWindow(element: XCUIElement) -> Bool {
    guard element.exists && !CGRectIsEmpty(element.frame) && element.hittable else { return false }
    return CGRectContainsRect(XCUIApplication().windows.elementBoundByIndex(0).frame, element.frame)
  }
  
  internal func scrollToElement(element: XCUIElement, threshold: Int = 5) {
    waitUntilExists(element)
    var iteration = 0
    
    while !elementIsWithinWindow(element) {
      guard iteration < threshold else { break }
      scrollDown()
      iteration++
    }
    
    if !elementIsWithinWindow(element) { scrollDown(threshold) }
    
    while !elementIsWithinWindow(element) {
      guard iteration > 0 else { break }
      scrollUp()
      iteration--
    }
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
    waitUntilExists(element)
    scrollToElement(element)
    waitUntilHittable(element)
    element.tap()
  }
}