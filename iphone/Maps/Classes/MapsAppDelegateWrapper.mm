#import "MapsAppDelegateWrapper.h"
#import "MapsAppDelegate.h"
#import "MapViewController.h"
#import "MWMMapViewControlsManager.h"
#import "DataConverter.h"

#include "Framework.h"
#include "geometry/mercator.hpp"
#include "geometry/point2d.hpp"
#include "geometry/rect2d.hpp"
#include "search/result.hpp"
#include "indexer/mwm_set.hpp"
#include "platform/mwm_version.hpp"

@implementation MapsAppDelegateWrapper
+ (UIViewController*)getMapViewController {
  return (UIViewController*)[MapsAppDelegate theApp].mapViewController;
}

+ (void)openPlacePage:(TripfingerEntity *)entity {
  [[MapsAppDelegate theApp].mapViewController.controlsManager showPlacePageWithEntityFullscreen:entity];
}

+ (void)openSearch {
  [[MapsAppDelegate theApp].mapViewController.controlsManager openSearch];
}

+ (void)openMapSearchWithQuery:(NSString*)query {
  [[MapsAppDelegate theApp].mapViewController.controlsManager openMapSearchWithQuery:query];
}

+ (void)navigateToRect:(CLLocationCoordinate2D)botLeft topRight:(CLLocationCoordinate2D)topRight {
  
  m2::PointD mercBotLeft = MercatorBounds::FromLatLon(botLeft.latitude, botLeft.longitude);
  m2::PointD mercTopRight = MercatorBounds::FromLatLon(topRight.latitude, topRight.longitude);

  m2::RectD mwmRect(mercBotLeft.x, mercBotLeft.y, mercTopRight.x, mercTopRight.y);
  GetFramework().GoToRect(mwmRect);
}

+ (void)selectListing:(TripfingerEntity *)entity {
  TripfingerMark mark = [DataConverter entityToMark:entity];
  FeatureID fid(mark);
  search::Result::Metadata metadata;
  m2::PointD centre(entity.lat, entity.lon);
  search::Result searchResult(fid, centre, "Harooo", "Adreees", "Typeee", entity.type, metadata);
  GetFramework().ShowSearchResult(searchResult);
}

+ (void)saveBookmark:(TripfingerEntity *)entity {
  Framework & f = GetFramework();
  BookmarkData bmData = { [entity.name UTF8String], "placemark-red" };
  size_t const categoryIndex = f.LastEditedBMCategory();
  m2::PointD mercator = MercatorBounds::FromLatLon(entity.lat, entity.lon);
  f.GetBookmarkManager().AddBookmark(categoryIndex, mercator, bmData);
}

+ (void)deleteBookmark:(TripfingerEntity *)entity {
  Framework & f = GetFramework();
  
  TripfingerMark mark = [DataConverter entityToMark:entity];
  BookmarkAndCategory bookmarkAndCat = f.FindBookmark(&mark);
  BookmarkCategory* bookmarkCat = f.GetBookmarkManager().GetBmCategory(bookmarkAndCat.first);
  BookmarkCategory::Guard guard(*bookmarkCat);
  guard.m_controller.DeleteUserMark(bookmarkAndCat.second);
  bookmarkCat->SaveToKMLFile();
}

@end

