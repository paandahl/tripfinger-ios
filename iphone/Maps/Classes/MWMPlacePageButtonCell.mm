#import "MWMPlacePage.h"
#import "MWMPlacePageButtonCell.h"
#import "Statistics.h"

#import "UIColor+MapsMeColor.h"

@interface MWMPlacePageButtonCell ()

@property (weak, nonatomic) MWMPlacePage * placePage;
@property (weak, nonatomic) IBOutlet UIButton * titleButton;
@property (nonatomic) BOOL isReport;
@property (nonatomic) BOOL isBooking;
@property (nonatomic) NSString * url;

@end

@implementation MWMPlacePageButtonCell

- (void)config:(MWMPlacePage *)placePage isReport:(BOOL)isReport
{
  self.placePage = placePage;
  self.isReport = isReport;
  self.isBooking = NO;
  [self.titleButton setTitleColor:isReport ? [UIColor red] : [UIColor linkBlue] forState:UIControlStateNormal];
  [self.titleButton setTitle:isReport ? L(@"placepage_report_problem_button") : L(@"edit_place") forState:UIControlStateNormal];
}

- (void)configBooking:(NSString *)url
{
  self.isBooking = YES;
  self.url = [url stringByAppendingString:@"?aid=884365"];
  [self.titleButton setTitleColor:[UIColor linkBlue] forState:UIControlStateNormal];
  [self.titleButton setTitle:@"Book on Booking.com" forState:UIControlStateNormal];
}

- (IBAction)buttonTap
{
  if (self.isBooking) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
    return;
  }
  
  [Statistics logEvent:kStatEventName(kStatPlacePage, self.isReport ? kStatReport : kStatEdit)];
  if (self.isReport)
    [self.placePage reportProblem];
  else
    [self.placePage editPlace];
}

@end
