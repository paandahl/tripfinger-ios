import XCTest
import CoreLocation
@testable import Tripfinger

class AppDelegateTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }

  func testCoordinateToInt() {
    var lat = 42.877001
    var lon = 74.570747
    var coord = CLLocationCoordinate2DMake(lat, lon)
    var coordInt = TripfingerAppDelegate.coordinateToInt(coord)
    XCTAssertEqual(104287700174570747, coordInt)

    lat = -142.877001
    lon = 74.570747
    coord = CLLocationCoordinate2DMake(lat, lon)
    coordInt = TripfingerAppDelegate.coordinateToInt(coord)
    XCTAssertEqual(314287700174570747, coordInt)

    lat = -142.877001
    lon = -4.570747
    coord = CLLocationCoordinate2DMake(lat, lon)
    coordInt = TripfingerAppDelegate.coordinateToInt(coord)
    XCTAssertEqual(414287700104570747, coordInt)

  }
}
  