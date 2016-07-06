import Foundation
import FirebaseAnalytics

class AnalyticsService {
  
  class func logSelectedRegion(region: Region) {
    FIRAnalytics.logEventWithName(kFIREventSelectContent, parameters: [
      kFIRParameterContentType: "region",
      kFIRParameterItemID: region.getName()
      ])
  }
  
  class func logSelectedListing(listing: Listing) {
    FIRAnalytics.logEventWithName(kFIREventSelectContent, parameters: [
      kFIRParameterContentType: "listing",
      kFIRParameterItemID: listing.item().name
      ])
  }
  
  class func logSelectedSection(section: GuideText, region: Region? = nil) {
    let itemId: String
    if let region = region {
      itemId = region.getName() + ": " + section.getName()
    } else {
      itemId = section.getName() + "(\(section.getId()))"
    }

    FIRAnalytics.logEventWithName(kFIREventSelectContent, parameters: [
      kFIRParameterContentType: "section",
      kFIRParameterItemID: itemId
      ])
  }
  
  class func logSelectedCategory(categoryDescription: GuideText, region: Region) {
    FIRAnalytics.logEventWithName(kFIREventSelectContent, parameters: [
      kFIRParameterContentType: "category",
      kFIRParameterItemID: region.getName() + ": " + categoryDescription.getCategory().entityName
      ])
  }
  
  class func logDownloadFirstCountry(country: Region) {
    FIRAnalytics.logEventWithName("first_download", parameters: [
      "country": country.getName()
      ])
  }
  
  class func logDownloadCountry(downloadId: String) {
    FIRAnalytics.logEventWithName("download_country", parameters: [
      "name": downloadId
      ])
  }
}