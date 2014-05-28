
#import "PlacePageInfoCell.h"
#import "UIKitCategories.h"
#import "LocationManager.h"
#import "MapsAppDelegate.h"
#import "SmallCompassView.h"
#import "Framework.h"
#include "../../../map/measurement_utils.hpp"
#include "../../../geometry/distance_on_sphere.hpp"
#import "ContextViews.h"

@interface PlacePageInfoCell () <LocationObserver, SelectedColorViewDelegate>

@property (nonatomic) UILabel * distanceLabel;
@property (nonatomic) CopyLabel * addressLabel;
@property (nonatomic) CopyLabel * coordinatesLabel;
@property (nonatomic) SmallCompassView * compassView;
@property (nonatomic) UIImageView * separator;
@property (nonatomic) SelectedColorView * selectedColorView;

@property (nonatomic) m2::PointD pinPoint;

@end

@implementation PlacePageInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  self.backgroundColor = [UIColor clearColor];

  [self addSubview:self.compassView];
  [self addSubview:self.distanceLabel];
  [self addSubview:self.addressLabel];
  [self addSubview:self.coordinatesLabel];
  [self addSubview:self.selectedColorView];

  UIImage * separatorImage = [[UIImage imageNamed:@"PlacePageSeparator"] resizableImageWithCapInsets:UIEdgeInsetsZero];
  CGFloat const offset = 15;
  UIImageView * separator = [[UIImageView alloc] initWithFrame:CGRectMake(offset, self.height - separatorImage.size.height, self.width - 2 * offset, separatorImage.size.height)];
  separator.image = separatorImage;
  separator.maxY = self.height;
  separator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
  [self addSubview:separator];
  self.separator = separator;

  [[MapsAppDelegate theApp].m_locationManager start:self];

  return self;
}

- (NSString *)distance
{
  CLLocation * location = [MapsAppDelegate theApp].m_locationManager.lastLocation;
  if (location)
  {
    double userLatitude = location.coordinate.latitude;
    double userLongitude = location.coordinate.longitude;
    double azimut = -1;
    double north = -1;

    [[MapsAppDelegate theApp].m_locationManager getNorthRad:north];

    string distance;
    GetFramework().GetDistanceAndAzimut(self.pinPoint, userLatitude, userLongitude, north, distance, azimut);
    return [NSString stringWithUTF8String:distance.c_str()];
  }
  return nil;
}

- (void)onLocationError:(location::TLocationError)errorCode
{
  NSLog(@"Location error in %@", [[self class] className]);
}

- (void)onLocationUpdate:(location::GpsInfo const &)info
{
  self.distanceLabel.text = [self distance];
}

- (void)onCompassUpdate:(location::CompassInfo const &)info
{
  double lat, lon;
  if (![[MapsAppDelegate theApp].m_locationManager getLat:lat Lon:lon])
    return;
  double const northRad = (info.m_trueHeading < 0) ? info.m_magneticHeading : info.m_trueHeading;
  m2::PointD const point1 = m2::PointD(MercatorBounds::LonToX(lon), MercatorBounds::LatToY(lat));
  m2::PointD const point2 = m2::PointD(self.pinPoint.x, self.pinPoint.y);

  self.compassView.angle = ang::AngleTo(point1, point2) + northRad;
}

- (void)setAddress:(NSString *)address pinPoint:(m2::PointD)point
{
  self.pinPoint = point;
  self.addressLabel.text = address;
  NSString * longitude = [NSString stringWithFormat:@"%.7f", MercatorBounds::XToLon(self.pinPoint.x)];
  NSString * latitude = [NSString stringWithFormat:@"%.7f", MercatorBounds::YToLat(self.pinPoint.y)];
  self.coordinatesLabel.text = [NSString stringWithFormat:@"%@, %@", longitude, latitude];

  self.distanceLabel.text = [self distance];
}

- (void)setColor:(UIColor *)color
{
  [self.selectedColorView setColor:color];
}

#define RIGHT_SHIFT 55

#define DISTANCE_LEFT_SHIFT 55

#define ADDRESS_FONT [UIFont fontWithName:@"HelveticaNeue-Light" size:17.5]
#define ADDRESS_LEFT_SHIFT 19

- (void)layoutSubviews
{
  CGFloat addressY;
  if ([MapsAppDelegate theApp].m_locationManager.lastLocation)
  {
    self.compassView.origin = CGPointMake(19, 17);
    self.compassView.hidden = NO;
    self.distanceLabel.frame = CGRectMake(DISTANCE_LEFT_SHIFT, 18, self.width - DISTANCE_LEFT_SHIFT - RIGHT_SHIFT, 24);
    self.distanceLabel.hidden = NO;
    addressY = 55;
  }
  else
  {
    self.compassView.hidden = YES;
    self.distanceLabel.hidden = YES;
    addressY = 15;
  }

  self.addressLabel.width = self.width - ADDRESS_LEFT_SHIFT - RIGHT_SHIFT;
  [self.addressLabel sizeToFit];
  self.addressLabel.origin = CGPointMake(ADDRESS_LEFT_SHIFT, addressY);

  self.coordinatesLabel.frame = CGRectMake(ADDRESS_LEFT_SHIFT, self.addressLabel.maxY + 10, self.width - ADDRESS_LEFT_SHIFT - RIGHT_SHIFT, 24);

  self.selectedColorView.center = CGPointMake(self.width - 32, 27);
}

+ (CGFloat)cellHeightWithAddress:(NSString *)address viewWidth:(CGFloat)viewWidth
{
  CGFloat addressHeight = [address sizeWithDrawSize:CGSizeMake(viewWidth - ADDRESS_LEFT_SHIFT - RIGHT_SHIFT, 200) font:ADDRESS_FONT].height;
  return addressHeight + ([MapsAppDelegate theApp].m_locationManager.lastLocation ? 110 : 66);
}

- (void)addressPress:(id)sender
{
  [self.delegate infoCellDidPressAddress:self withGestureRecognizer:sender];
}

- (void)coordinatesPress:(id)sender
{
  [self.delegate infoCellDidPressCoordinates:self withGestureRecognizer:sender];
}

- (void)selectedColorViewDidPress:(SelectedColorView *)selectedColorView
{
  [self.delegate infoCellDidPressColorSelector:self];
}

- (UILabel *)distanceLabel
{
  if (!_distanceLabel)
  {
    _distanceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _distanceLabel.backgroundColor = [UIColor clearColor];
    _distanceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.5];
    _distanceLabel.textAlignment = NSTextAlignmentLeft;
    _distanceLabel.textColor = [UIColor whiteColor];
    _distanceLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
  }
  return _distanceLabel;
}

- (CopyLabel *)addressLabel
{
  if (!_addressLabel)
  {
    _addressLabel = [[CopyLabel alloc] initWithFrame:CGRectZero];
    _addressLabel.backgroundColor = [UIColor clearColor];
    _addressLabel.font = ADDRESS_FONT;
    _addressLabel.textAlignment = NSTextAlignmentLeft;
    _addressLabel.textColor = [UIColor whiteColor];
    _addressLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    UILongPressGestureRecognizer * press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addressPress:)];
    [_addressLabel addGestureRecognizer:press];
  }
  return _addressLabel;
}

- (CopyLabel *)coordinatesLabel
{
  if (!_coordinatesLabel)
  {
    _coordinatesLabel = [[CopyLabel alloc] initWithFrame:CGRectZero];
    _coordinatesLabel.backgroundColor = [UIColor clearColor];
    _coordinatesLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.5];
    _coordinatesLabel.textAlignment = NSTextAlignmentLeft;
    _coordinatesLabel.textColor = [UIColor whiteColor];
    _coordinatesLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    UILongPressGestureRecognizer * press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(coordinatesPress:)];
    [_coordinatesLabel addGestureRecognizer:press];
  }
  return _coordinatesLabel;
}

- (SelectedColorView *)selectedColorView
{
  if (!_selectedColorView)
  {
    _selectedColorView = [[SelectedColorView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    _selectedColorView.delegate = self;
    _selectedColorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
  }
  return _selectedColorView;
}

- (SmallCompassView *)compassView
{
  if (!_compassView)
    _compassView = [[SmallCompassView alloc] init];
  return _compassView;
}

- (void)dealloc
{
  [[MapsAppDelegate theApp].m_locationManager stop:self];
}

@end
