#import "MWMOpeningHours.h"
#include "3party/opening_hours/opening_hours.hpp"
#include "editor/opening_hours_ui.hpp"
#include "editor/ui2oh.hpp"
#include "base/assert.hpp"

using namespace editor;
using namespace osmoh;

@implementation MWMOpeningHours
  
  RCT_EXPORT_MODULE();
  
  RCT_REMAP_METHOD(createOpeningHoursDict, timeString:(NSString*)timeString resolver:(RCTPromiseResolveBlock)resolve
                   rejecter:(RCTPromiseRejectBlock)reject)
  {
    resolve([MWMOpeningHours createOpeningHoursDict:timeString]);
  }

  + (NSDictionary*)createOpeningHoursDict:(NSString*)timeString {
    ui::TimeTableSet timeTableSet;
    osmoh::OpeningHours oh(timeString.UTF8String);
    NSMutableDictionary* timeDict = [[NSMutableDictionary alloc] init];
    if (MakeTimeTableSet(oh, timeTableSet))
    {
      BOOL isClosed = oh.IsClosed(time(nullptr));
      NSMutableArray* weekdays = [[NSMutableArray alloc] init];
      
      NSCalendar * cal = [NSCalendar currentCalendar];
      cal.locale = [NSLocale currentLocale];
      Weekday currentDay = static_cast<Weekday>([cal components:NSCalendarUnitWeekday fromDate:[NSDate date]].weekday);
      BOOL haveCurrentDay = NO;
      size_t timeTablesCount = timeTableSet.Size();
      BOOL haveExpandSchedule = (timeTablesCount > 1 || !timeTableSet.GetUnhandledDays().empty());
      //      self.weekDaysViewEstimatedHeight = 0.0;
      //      [self.weekDaysView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
      for (size_t idx = 0; idx < timeTablesCount; ++idx)
      {
        ui::TTimeTableProxy tt = timeTableSet.Get(idx);
        ui::TOpeningDays const & workingDays = tt.GetOpeningDays();
        if (workingDays.find(currentDay) != workingDays.end())
        {
          haveCurrentDay = YES;
          timeDict[@"currentDay"] = [self addCurrentDay:tt];
        }
        [weekdays addObject:[self addWeekDays:tt]];
        
      }
      if (!haveCurrentDay) {
        timeDict[@"currentDay"] = [self addEmptyCurrentDay];
      }
      timeDict[@"currentDay"][@"closed"] = [NSNumber numberWithBool:isClosed];
      if (haveExpandSchedule) {
        editor::ui::TOpeningDays closedDays = timeTableSet.GetUnhandledDays();
        if (!closedDays.empty()) {
          timeDict[@"closedDays"] = [self stringFromOpeningDays:closedDays];
        }
      }
      
      timeDict[@"weekdays"] = weekdays;
    }
    else
    {
      timeDict[@"plainText"] = timeString;
    }
    return timeDict;
  }
  
  + (NSMutableDictionary*)addCurrentDay:(ui::TTimeTableProxy)timeTable
  {
    NSMutableDictionary* dayDict = [[NSMutableDictionary alloc] init];
    NSString * label;
    NSString * openTime;
    NSArray<NSString *> * breaks;
    
    if (timeTable.IsTwentyFourHours()) {
      label = @"24/7";
      openTime = @"";
      breaks = @[];
    } else
    {
      BOOL const everyDay = (timeTable.GetOpeningDays().size() == 7);
      label = everyDay ? @"Daily" : @"Today";
      openTime = [self stringFromTimeSpan:timeTable.GetOpeningTime()];
      breaks = [self arrayFromClosedTimes:timeTable.GetExcludeTime()];
    }
    
    dayDict[@"label"] = label;
    dayDict[@"openTime"] = openTime;
    dayDict[@"breaks"] = breaks;
    return dayDict;
  }
  
  + (NSDictionary*)addEmptyCurrentDay {
    NSMutableDictionary* dayDict = [[NSMutableDictionary alloc] init];
    dayDict[@"label"] = @"Closed today";
    dayDict[@"openTime"] = @"";
    dayDict[@"breaks"] = @[];
    dayDict[@"closed"] = [NSNumber numberWithBool:NO];
    return dayDict;
  }
  
  + (NSDictionary*)addWeekDays:(ui::TTimeTableProxy)timeTable {
    NSMutableDictionary* dayDict = [[NSMutableDictionary alloc] init];
    dayDict[@"label"] = [self stringFromOpeningDays:timeTable.GetOpeningDays()];
    if (timeTable.IsTwentyFourHours())
    {
      dayDict[@"openTime"] = @"24/7";
      dayDict[@"breaks"] = @[];
    }
    else
    {
      dayDict[@"openTime"] = [self stringFromTimeSpan:timeTable.GetOpeningTime()];
      dayDict[@"breaks"] = [self arrayFromClosedTimes:timeTable.GetExcludeTime()];
    }
    return dayDict;
  }
  
  + (NSString*)stringFromTimeSpan:(Timespan)timeSpan {
    return [NSString stringWithFormat:@"%@ - %@", [self stringFromTime:timeSpan.GetStart()], [self stringFromTime:timeSpan.GetEnd()]];
  }

  + (NSArray<NSString*>*)arrayFromClosedTimes:(TTimespans)closedTimes
  {
    NSMutableArray<NSString *> * breaks = [NSMutableArray arrayWithCapacity:closedTimes.size()];
    for(auto & ct : closedTimes)
    {
      [breaks addObject:[self stringFromTimeSpan:ct]];
    }
    return [breaks copy];
  }
  
  + (NSDateComponents*)dateComponentsFromTime:(osmoh::Time)time {
    NSDateComponents * dc = [[NSDateComponents alloc] init];
    dc.hour = time.GetHoursCount();
    dc.minute = time.GetMinutesCount();
    return dc;
  }
  
  + (NSDate*)dateFromTime:(osmoh::Time)time {
    NSCalendar * cal = [NSCalendar currentCalendar];
    cal.locale = [NSLocale currentLocale];
    return [cal dateFromComponents:[self dateComponentsFromTime:time]];
  }
  
  + (NSString*)stringFromTime:(osmoh::Time)time {
    NSDateFormatter * fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [NSLocale currentLocale];
    fmt.timeStyle = NSDateFormatterShortStyle;
    fmt.dateStyle = NSDateFormatterNoStyle;
    return [fmt stringFromDate:[self dateFromTime:time]];
  }
  
  + (NSString*)stringFromOpeningDays:(editor::ui::TOpeningDays)openingDays {
    NSCalendar * cal = [NSCalendar currentCalendar];
    cal.locale = [NSLocale currentLocale];
    NSUInteger const firstWeekday = cal.firstWeekday - 1;
    
    NSArray<NSString *> * weekdaySymbols = cal.shortStandaloneWeekdaySymbols;
    NSMutableArray<NSString *> * spanNames = [NSMutableArray arrayWithCapacity:2];
    NSMutableArray<NSString *> * spans = [NSMutableArray array];
    
    auto weekdayFromDay = ^(NSUInteger day)
    {
      NSUInteger idx = day + 1;
      if (idx > static_cast<NSUInteger>(osmoh::Weekday::Saturday))
      idx -= static_cast<NSUInteger>(osmoh::Weekday::Saturday);
      return static_cast<osmoh::Weekday>(idx);
    };
    
    auto joinSpanNames = ^
    {
      NSUInteger const spanNamesCount = spanNames.count;
      if (spanNamesCount == 0)
      return;
      else if (spanNamesCount == 1)
      [spans addObject:spanNames[0]];
      else if (spanNamesCount == 2)
      [spans addObject:[spanNames componentsJoinedByString:@"-"]];
      else
      ASSERT(false, ("Invalid span names count."));
      [spanNames removeAllObjects];
    };
    NSUInteger const weekDaysCount = 7;
    for (NSUInteger i = 0, day = firstWeekday; i < weekDaysCount; ++i, ++day)
    {
      osmoh::Weekday const wd = weekdayFromDay(day);
      if (openingDays.find(wd) == openingDays.end())
      joinSpanNames();
      else
      spanNames[(spanNames.count == 0 ? 0 : 1)] = weekdaySymbols[static_cast<NSInteger>(wd) - 1];
    }
    joinSpanNames();
    return [spans componentsJoinedByString:@", "];
  }
  
  @end
