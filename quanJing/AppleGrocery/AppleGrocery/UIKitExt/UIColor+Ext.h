#import <UIKit/UIKit.h>

@interface UIColor (Ext)

+(UIColor *)randomColor;
+(UIColor *)randomColorWithAlpha:(float)alpha;

-(UIColor *)colorByChangingAlphaTo:(CGFloat)alpha;

@end
