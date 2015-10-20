#import "UIView+UIExt.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (UIExt)

- (CGSize)calcSizeToFitSubviews
{
    float w = 0;
    float h = 0;
    
    for (UIView *v in [self subviews]) {
        float fw = v.frame.origin.x + v.frame.size.width;
        float fh = v.frame.origin.y + v.frame.size.height;
        w = MAX(fw, w);
        h = MAX(fh, h);
    }
    
    return CGSizeMake(w, h);
}

- (void)resizeToFitSubviews
{
    CGSize size = [self calcSizeToFitSubviews];
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height)];
}

- (void)setShouldRasterize:(BOOL)shouldRasterize
{
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

@end
