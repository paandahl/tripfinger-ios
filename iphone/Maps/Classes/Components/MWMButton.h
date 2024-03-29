typedef NS_ENUM(NSUInteger, MWMButtonColoring)
{
  MWMButtonColoringOther,
  MWMButtonColoringBlue,
  MWMButtonColoringBlack,
  MWMButtonColoringGray
};

@interface MWMButton : UIButton

@property (copy, nonatomic) NSString * imageName;
@property (nonatomic) MWMButtonColoring coloring;

@end
