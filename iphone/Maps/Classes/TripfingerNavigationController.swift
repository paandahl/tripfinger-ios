import Foundation

class TripfingerNavigationController: UINavigationController {
  override func supportedInterfaceOrientations() -> UInt {
    let className = String(topViewController!.dynamicType)
    if className == "MapViewController" {
      return UInt(UIInterfaceOrientationMask.All.rawValue)
    } else {
      return UInt(UIInterfaceOrientationMask.Portrait.rawValue)
    }
  }
  
  func alert(message: String) {
    let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .Alert)
    let defaultAction = UIAlertAction(title: "OK", style: .Default) { alertAction in
      self.dismissViewControllerAnimated(true, completion: nil)
    }
    alertController.addAction(defaultAction)
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  func navigateToTripfingerUrl(url: TripfingerUrl, failure: () -> (), finishedHandler: () -> ()) {
    let regionSlug = url.regionSlug()
    ContentService.getRegionWithSlug(regionSlug, failure: failure) { region in
      ContentService.getCountryForRegion(region, failure: failure) { country in
        if let listingSlug = url.listingSlug() {
          ContentService.getListingWithSlug(listingSlug, failure: failure) { listing in
            self.navigateToListing(listing, countryMwmId: country.getDownloadId())
            finishedHandler()
          }
        } else {
          self.navigateToRegion(region, countryMwmId: country.getDownloadId())
          finishedHandler()
        }
      }
    }
  }
  
  func navigateToRegion(region: Region, countryMwmId: String) {
    let regionController = RegionController(region: region, countryMwmId: countryMwmId)
    TripfingerAppDelegate.navigationController.pushViewController(regionController, animated: true)
    AnalyticsService.logSelectedRegion(region)
  }
  
  func navigateToListing(listing: Listing, countryMwmId: String) {
    let entity = TripfingerEntity(listing: listing)
    MapsAppDelegateWrapper.openPlacePage(entity, withCountryMwmId: countryMwmId)
    AnalyticsService.logSelectedListing(listing)
  }

  func jumpToRegionWithSlug(slug: String, failure: () -> (), finishedHandler: () -> ()) {
    ContentService.getRegionWithSlug(slug, failure: failure) { region in
      self.jumpToRegion(region, failure: failure, finishedHandler: finishedHandler)
    }
  }
  
  func jumpToRegionWithId(regionId: String, failure: () -> (), finishedHandler: () -> ()) {
    ContentService.getRegionWithId(regionId, failure: failure) { region in
      self.jumpToRegion(region, failure: failure, finishedHandler: finishedHandler)
    }
  }
  
  private func jumpToRegion(region: Region, failure: () -> (), finishedHandler: () -> ()) {
    self.prepareJumpToRegion(region, stopSpinner: finishedHandler) { country, nav, viewControllers in
      nav.setViewControllers(viewControllers, animated: true)
    }
    AnalyticsService.logSelectedRegion(region)
  }
  
  func jumpToListingWithSlug(slug: String, failure: () -> (), finishedHandler: () -> ()) {
    ContentService.getListingWithSlug(slug, failure: failure) { listing in
      self.jumpToListing(listing, failure: failure, finishedHandler: finishedHandler)
    }
  }
  
  func jumpToListingWithId(listingId: String, failure: () -> (), finishedHandler: () -> ()) {
    ContentService.getListingWithId(listingId, failure: failure) { listing in
      self.jumpToListing(listing, failure: failure, finishedHandler: finishedHandler)
    }
  }
  
  private func jumpToListing(listing: Listing, failure: () -> (), finishedHandler: () -> ()) {
    ContentService.getRegionWithId(listing.item().parent, failure: failure) { region in
      self.prepareJumpToRegion(region, stopSpinner: finishedHandler) { countryMwmId, nav, viewControllers in
        let entity = TripfingerEntity(listing: listing)
        TripfingerAppDelegate.viewControllers = viewControllers
        MapsAppDelegateWrapper.openPlacePage(entity, withCountryMwmId: countryMwmId)
      }
    }
    AnalyticsService.logSelectedListing(listing)
  }

  private func prepareJumpToRegion(region: Region, stopSpinner: () -> (), handler: (String, UINavigationController, [UIViewController]) -> ()) {
    ContentService.getCountryForRegion(region, failure: connectionError) { country in
      self.prepareJumpToRegion(region, countryMwmId: country.getDownloadId(), stopSpinner: stopSpinner, handler: handler)
    }
  }
  
  private func prepareJumpToRegion(region: Region, countryMwmId: String, stopSpinner: () -> (), handler: (String, UINavigationController, [UIViewController]) -> ()) {
    stopSpinner()
    
    let nav = TripfingerAppDelegate.navigationController
    for viewController in nav.viewControllers {
      if let regionController = viewController as? GuideItemController {
        regionController.contextSwitched = true
      }
    }
    
    nav.popToRootViewControllerAnimated(false)
    let regionListing = region.listing
    var viewControllers = [nav.viewControllers.first!]
    if region.item().category > Region.Category.COUNTRY.rawValue {
      let regionController = RegionController(region: Region.constructRegion(regionListing.country), countryMwmId: countryMwmId)
      viewControllers.append(regionController)
    }
    if region.item().category > Region.Category.SUB_REGION.rawValue {
      if region.listing.subRegion != nil {
        let regionController = RegionController(region: Region.constructRegion(regionListing.subRegion), countryMwmId: countryMwmId)
        viewControllers.append(regionController)
      }
    }
    if region.item().category > Region.Category.CITY.rawValue {
      let regionController = RegionController(region: Region.constructRegion(regionListing.city), countryMwmId: countryMwmId)
      viewControllers.append(regionController)
    }
    let regionController = RegionController(region: region, countryMwmId: countryMwmId)
    viewControllers.append(regionController)
    
    handler(countryMwmId, nav, viewControllers)
  }
  
  private func connectionError() {
    viewControllers.last!.showErrorHud()
  }
}
