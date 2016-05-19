import Foundation

class FrameworkService {
  
  class func navigateToRegionOnMap(region: Region) {
    let margin: Double
    switch region.getCategory() {
    case .COUNTRY:
      margin = 6
    case .SUB_REGION:
      margin = 1
    case .CITY:
      margin = 0.5
    case .NEIGHBOURHOOD:
      margin = 0.2
    default:
      margin = 0.2
    }
    let botLeft = CLLocationCoordinate2DMake(region.listing.latitude - margin, region.listing.longitude - margin)
    let topRight = CLLocationCoordinate2DMake(region.listing.latitude + margin, region.listing.longitude + margin)
    MapsAppDelegateWrapper.navigateToRect(botLeft, topRight: topRight)
  }
}