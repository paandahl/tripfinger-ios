import Foundation

class TripfingerUrl {
  
  private let url: NSURL
  
  init?(url: NSURL) {
    if url.host == "www.tripfinger.com" {
      self.url = url
    } else {
      return nil
    }
  }
  
  func regionSlug() -> String {
    return regionPath().characters.split{$0 == "/"}.map(String.init).last!
  }
  
  private func regionPath() -> String {
    if isListing() {
      let listingPartStart = url.path!.rangeOfString("/l/")
      return url.path!.substringToIndex(listingPartStart!.startIndex)
    } else {
      return url.path!
    }
  }
  
  func listingSlug() -> String? {
    if isListing() {
      let listingPartStart = url.path!.rangeOfString("/l/")
      return url.path!.substringFromIndex(listingPartStart!.endIndex)
    } else {
      return nil
    }
  }
  
  func isListing() -> Bool {
    return url.path!.containsString("/l/")
  }
}