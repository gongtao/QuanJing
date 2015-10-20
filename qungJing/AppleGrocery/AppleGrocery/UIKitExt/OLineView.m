#import "OLineView.h"

@implementation OLineView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.opaque = NO;
    _lineWidth = 1;
    _lineColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    _lineShadowColor = [UIColor colorWithWhite:1.0 alpha:0.75];
    _lineShadowOffsetY = 1;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(1, _lineWidth + ((_lineShadowColor != nil) ? _lineShadowOffsetY : 0));
}

- (void)drawRect:(CGRect)rect
{
    CGPoint lineStart = { _lineWidth * 0.5, _lineWidth * 0.5 };
    CGPoint lineEnd = { self.bounds.size.width - _lineWidth * 0.5, _lineWidth * 0.5 };

    CGContextRef context = UIGraphicsGetCurrentContext();
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: lineStart];
    [bezierPath addLineToPoint: lineEnd];
    CGContextSaveGState(context);
    if (_lineShadowColor != nil)
    {
        CGContextSetShadowWithColor(context, CGSizeMake(0.0, _lineShadowOffsetY), 0, _lineShadowColor.CGColor);
    }
    [_lineColor setStroke];
    bezierPath.lineWidth = _lineWidth;
    [bezierPath stroke];
    CGContextRestoreGState(context);
}

@end
