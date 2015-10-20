#import "OViewPagerTabView.h"

@implementation OViewPagerTabView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    // Update view as state changed
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath* bezierPath;

#if 0
    // Draw top line
    bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(0.0, 0.0)];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect), 0.0)];
    [[UIColor colorWithWhite:197.0 / 255.0 alpha:0.75] setStroke];
    [bezierPath setLineWidth:1.0];
    [bezierPath stroke];
#endif

#if 0
    // Draw bottom line
    bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(0.0, CGRectGetHeight(rect))];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect))];
    [[UIColor colorWithWhite:197.0 / 255.0 alpha:0.75] setStroke];
    [bezierPath setLineWidth:1.0];
    [bezierPath stroke];
#endif

    // Draw an indicator line if tab is selected
    if (self.selected)
    {
        bezierPath = [UIBezierPath bezierPath];

        // Draw the indicator
        [bezierPath moveToPoint:CGPointMake(0.0, CGRectGetHeight(rect) - 1.0)];
        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect) - 1.0)];
        [bezierPath setLineWidth:5.0];
        [self.indicatorColor setStroke];
        [bezierPath stroke];
    }
}

@end
