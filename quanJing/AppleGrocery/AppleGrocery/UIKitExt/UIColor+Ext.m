#import "UIColor+Ext.h"

@implementation UIColor (Ext)

+ (UIColor *)randomColor
{
    return [UIColor randomColorWithAlpha:1.0];
}

+(UIColor *)randomColorWithAlpha:(float)alpha
{
    CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

-(UIColor *)colorByChangingAlphaTo:(CGFloat)alpha
{
    CGColorRef oldColor = CGColorCreateCopyWithAlpha([self CGColor], alpha);
    UIColor* newColor = [UIColor colorWithCGColor:oldColor];
    CGColorRelease(oldColor);
    return newColor;
}

@end
