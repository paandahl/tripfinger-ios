#import "Common.h"
#import "MWMMapDownloaderDefaultDataSource.h"
#import "MWMStorage.h"
#import "Statistics.h"
#import "DataConverter.h"

#include "Framework.h"
#import "SwiftBridge.h"

extern NSString * const kCountryCellIdentifier;
extern NSString * const kSubplaceCellIdentifier;
extern NSString * const kPlaceCellIdentifier;
extern NSString * const kLargeCountryCellIdentifier;

namespace
{
auto compareStrings = ^NSComparisonResult(NSString * s1, NSString * s2)
{
  return [s1 compare:s2 options:NSCaseInsensitiveSearch range:{0, s1.length} locale:[NSLocale currentLocale]];
};

auto compareLocalNames = ^NSComparisonResult(NSString * s1, NSString * s2)
{
  auto const & s = GetFramework().Storage();
  string l1 = s.GetNodeLocalName(s1.UTF8String);
  string l2 = s.GetNodeLocalName(s2.UTF8String);
  return compareStrings(@(l1.c_str()), @(l2.c_str()));
};
} // namespace

using namespace storage;

@interface MWMMapDownloaderDataSource ()

@property (nonatomic, readwrite) BOOL needFullReload;

@end

@interface MWMMapDownloaderDefaultDataSource ()

@property (copy, nonatomic) NSArray<NSString *> * indexes;
@property (copy, nonatomic) NSDictionary<NSString *, NSArray<NSString *> *> * availableCountries;
@property (copy, nonatomic) NSArray<NSString *> * downloadedCountries;

@end

@implementation MWMMapDownloaderDefaultDataSource
{
  TCountryId m_parentId;
}

@synthesize isParentRoot = _isParentRoot;

- (instancetype)initForRootCountryId:(NSString *)countryId delegate:(id<MWMMapDownloaderProtocol>)delegate
{
  self = [super initWithDelegate:delegate];
  if (self)
  {
    m_parentId = countryId.UTF8String;
    _isParentRoot = (m_parentId == GetFramework().Storage().GetRootId());
    [self load];
  }
  return self;
}

- (void)load
{
  auto const & s = GetFramework().Storage();
  TCountriesVec downloadedChildren;
  TCountriesVec availableChildren;
  NSLog(@"Getting children for parent: %@", @(m_parentId.c_str()));
  s.GetChildrenInGroups(m_parentId, downloadedChildren, availableChildren);
  if (downloadedChildren.empty() && availableChildren.empty()) {
    NodeAttrs nodeAttrs;
    s.GetNodeAttrs(m_parentId, nodeAttrs);
    if (nodeAttrs.m_status == NodeStatus::NotDownloaded) {
      availableChildren.push_back(m_parentId);
    } else {
      downloadedChildren.push_back(m_parentId);
    }
  }
  [self configAvailableSections:availableChildren];
  [self configDownloadedSection:downloadedChildren];
}

- (void)reload
{
  [self.reloadSections removeAllIndexes];
  // Get old data for comparison.
  NSDictionary<NSString *, NSArray<NSString *> *> * availableCountriesBeforeUpdate = self.availableCountries;
  NSInteger const downloadedCountriesCountBeforeUpdate = self.downloadedCountries.count;

  // Load updated data.
  [self load];

  // Compare new data vs old data to understand what kind of reload is required and what sections need reload.
  NSInteger const downloadedCountriesCountAfterUpdate = self.downloadedCountries.count;
  self.needFullReload =
      (downloadedCountriesCountBeforeUpdate == 0 || downloadedCountriesCountAfterUpdate == 0 ||
       availableCountriesBeforeUpdate.count != self.availableCountries.count ||
       availableCountriesBeforeUpdate.count == 0);
  if (self.needFullReload)
    return;
  [availableCountriesBeforeUpdate enumerateKeysAndObjectsUsingBlock:^(NSString * key, NSArray<NSString *> * obj, BOOL * stop)
  {
    NSUInteger const sectionIndex = [self.indexes indexOfObject:key];
    if (sectionIndex == NSNotFound)
    {
      self.needFullReload = YES;
      *stop = YES;
    }
    else if (obj.count != self.availableCountries[key].count)
    {
      [self.reloadSections addIndex:sectionIndex];
    }
  }];
  [self.reloadSections shiftIndexesStartingAtIndex:0 by:self.downloadedSectionShift];
  if (downloadedCountriesCountBeforeUpdate != downloadedCountriesCountAfterUpdate)
    [self.reloadSections addIndex:self.downloadedSection];
}

- (void)configAvailableSections:(TCountriesVec const &)availableChildren
{
  BOOL const isParentRoot = self.isParentRoot;
  NSInteger indexSize = self.isParentRoot ? availableChildren.size() : availableChildren.size() + 1;
  NSMutableSet<NSString *> * indexSet = [NSMutableSet setWithCapacity:indexSize];
  NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> * availableCountries = [@{} mutableCopy];
  NSInteger downloadStatus = [TripfingerAppDelegate downloadStatus:@(m_parentId.c_str())];
  NodeStatus nodeStatus = static_cast<NodeStatus>(downloadStatus);
  if (!self.isParentRoot && nodeStatus == NodeStatus::NotDownloaded) {
    NSString * guideIndex = @"Available guide";
    [indexSet addObject:guideIndex];
    NSMutableArray<NSString *> * guideArray = [@[] mutableCopy];
    [guideArray addObject:[@"guide" stringByAppendingString:self.parentCountryId]];
    availableCountries[guideIndex] = guideArray;
  }
  auto const & s = GetFramework().Storage();
  for (auto const & countryId : availableChildren)
  {
    NSString * nsCountryId = @(countryId.c_str());
    string localName = s.GetNodeLocalName(countryId);
    NSString * index = isParentRoot ? [@(localName.c_str()) substringToIndex:1].capitalizedString : L(@"downloader_available_maps");
    [indexSet addObject:index];

    NSMutableArray<NSString *> * letterIds = availableCountries[index];
    letterIds = letterIds ? letterIds : [@[] mutableCopy];
    [letterIds addObject:nsCountryId];
    availableCountries[index] = letterIds;
  }
  self.indexes = [[indexSet allObjects] sortedArrayUsingComparator:compareStrings];
  [availableCountries enumerateKeysAndObjectsUsingBlock:^(NSString * key, NSMutableArray<NSString *> * obj, BOOL * stop)
  {
    [obj sortUsingComparator:compareLocalNames];
  }];
  self.availableCountries = availableCountries;
}

- (void)configDownloadedSection:(TCountriesVec const &)downloadedChildren
{
  NSMutableArray<NSString *> * downloadedCountries = [@[] mutableCopy];
  for (auto const & countryId : downloadedChildren)
    [downloadedCountries addObject:@(countryId.c_str())];
  NSInteger downloadStatus = [TripfingerAppDelegate downloadStatus:@(m_parentId.c_str())];
  NodeStatus nodeStatus = static_cast<NodeStatus>(downloadStatus);
  if (!self.isParentRoot && nodeStatus != NodeStatus::NotDownloaded && nodeStatus != NodeStatus::Undefined) {
    downloadedCountries = [NSMutableArray arrayWithArray:[downloadedCountries sortedArrayUsingComparator:compareLocalNames]];
    [downloadedCountries insertObject:[@"guide" stringByAppendingString:self.parentCountryId] atIndex:0];
    self.downloadedCountries = downloadedCountries;
  } else {
    self.downloadedCountries = [downloadedCountries sortedArrayUsingComparator:compareLocalNames];
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return self.indexes.count + self.downloadedSectionShift;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section == self.downloadedSection)
    return self.downloadedCountries.count;
  NSString * index = self.indexes[section - self.downloadedSectionShift];
  return self.availableCountries[index].count;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
  return self.isParentRoot ? self.indexes : nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
  return index + self.downloadedSectionShift;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  if (section == self.downloadedSection)
  {
    NodeAttrs nodeAttrs;
    GetFramework().Storage().GetNodeAttrs(m_parentId, nodeAttrs);
    if (nodeAttrs.m_localMwmSize == 0)
      return [NSString stringWithFormat:@"%@", L(@"downloader_downloaded_subtitle")];
    else
      return [NSString stringWithFormat:@"%@ (%@)", L(@"downloader_downloaded_subtitle"), formattedSize(nodeAttrs.m_localMwmSize)];
  }
  return self.indexes[section - self.downloadedSectionShift];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
  return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  NodeAttrs nodeAttrs;
  string countryId = [self countryIdForIndexPath:indexPath].UTF8String;
  NodeStatus status;
  if (boost::starts_with(countryId, "guide")) {
    nodeAttrs = [DataConverter getNodeAttrs:countryId];
  } else {
    GetFramework().Storage().GetNodeAttrs(countryId, nodeAttrs);
  }
  status = nodeAttrs.m_status;
  return (status == NodeStatus::OnDisk || status == NodeStatus::OnDiskOutOfDate || nodeAttrs.m_localMwmCounter != 0);
}

#pragma mark - MWMMapDownloaderDataSource

- (NSString *)parentCountryId
{
  return @(m_parentId.c_str());
}

- (NSString *)countryIdForIndexPath:(NSIndexPath *)indexPath
{
  NSInteger const section = indexPath.section;
  NSInteger const row = indexPath.row;
  if (section == self.downloadedSection)
    return self.downloadedCountries[row];
  NSString * index = self.indexes[section - self.downloadedSectionShift];
  NSArray<NSString *> * availableCountries = self.availableCountries[index];
  NSString * nsCountryId = availableCountries[indexPath.row];
  return nsCountryId;
}

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath
{
  auto const & s = GetFramework().Storage();
  TCountriesVec children;
  string countryId = [self countryIdForIndexPath:indexPath].UTF8String;
  if (boost::starts_with(countryId, "guide")) {
    countryId = countryId.substr(5);
  }
  s.GetChildren(countryId, children);
  BOOL const haveChildren = !children.empty();
//  if (haveChildren)
//    return kLargeCountryCellIdentifier;
  return self.isParentRoot ? kLargeCountryCellIdentifier : kPlaceCellIdentifier;
}

#pragma mark - Properties

- (NSInteger)downloadedSectionShift
{
  return (self.downloadedCountries.count != 0 ? self.downloadedSection + 1 : 0);
}

- (NSInteger)downloadedSection
{
  return self.downloadedCountries.count != 0 ? 0 : NSNotFound;
}

@end
