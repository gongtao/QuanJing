#import "ODashLineView.h"

@implementation ODashLineView

@synthesize lineColor, vertical, dashes;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.lineWidth = 1.0;
        self.lineColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        self.vertical = false;
        self.dashes = nil;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.lineWidth = 1.0;
        self.lineColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        self.vertical = false;
        self.dashes = nil;
    }
    return self;
}

- (float)lineWidth
{
    return _lineWidth;
}

- (void)setLineWidth:(float)lineWidth
{
    _lineWidth = lineWidth;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetStrokeColorWithColor(context, [self.lineColor CGColor]);

    if (self.dashes != nil)
    {
        CGFloat* dashFloats = (CGFloat *) malloc(sizeof(CGFloat) * [self.dashes count]);

        NSEnumerator* enumerator = [self.dashes objectEnumerator];
        id floatObject;
        int index = 0;
        while (floatObject = [enumerator nextObject])
        {
            dashFloats[index++] = [floatObject floatValue];
        }
        
        CGContextSetLineDash(context, 0.0, dashFloats, [self.dashes count]);
        free(dashFloats);
    }

    CGContextSetLineWidth(context, _lineWidth);


    if (self.vertical)
    {
        float midX = CGRectGetMidX(rect);
        float minY = CGRectGetMinY(rect);
        float maxY = CGRectGetMaxY(rect);
        CGContextMoveToPoint(context, midX, minY);
        CGContextAddLineToPoint(context, midX, maxY);
    }
    else
    {
        CGContextMoveToPoint(context, CGRectGetMinX(rect), _lineWidth * 0.5);
        CGContextAddLineToPoint(context, CGRectGetMaxX(rect), _lineWidth * 0.5);
    }

    CGContextStrokePath(context);
}

@end
