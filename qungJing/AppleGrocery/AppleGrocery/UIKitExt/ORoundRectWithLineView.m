//
//  ORoundRectWithLineView.m
//  Weitu
//
//  Created by Su on 3/29/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "ORoundRectWithLineView.h"
#import "OLineView.h"

@interface ORoundRectWithLineView()

@end

@implementation ORoundRectWithLineView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
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
    [super setup];

    _lineWidth = 0.5;
    _lineColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    _lineShadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    _lineShadowOffsetY = 0.5;
    _segmentNum = 1;
#if 0
    [self updateLines];
#endif
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect drawingRect = CGRectInset(self.bounds, super.marginX, super.marginY);
    CGFloat startX = drawingRect.origin.x;
    CGFloat endX = startX + drawingRect.size.width;
    for (NSInteger i = 1; i < _segmentNum; ++i)
    {
        CGFloat y = drawingRect.size.height * (CGFloat)i / (CGFloat)_segmentNum;
        y = roundf(y * 2.0) / 2.0 + _lineWidth * 0.5;
        [self drawLineFrom:CGPointMake(startX, y)
                        to:CGPointMake(endX, y)
                   context:context];
    }
}

- (void)setSegmentNum:(NSInteger)segmentNum
{
    if (segmentNum < 1)
    {
        return;
    }
    
    if (_segmentNum != segmentNum)
    {
        _segmentNum = segmentNum;
        [self setNeedsDisplay];
    }
}

- (void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
    [self setNeedsDisplay];
}

- (void)setLineShadowColor:(UIColor *)lineShadowColor
{
    _lineShadowColor = lineShadowColor;
    [self setNeedsDisplay];
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    if (lineWidth != _lineWidth)
    {
        _lineWidth = lineWidth;
    }
}

- (void)drawLineFrom:(CGPoint)lineStart
                  to:(CGPoint)lineEnd
             context:(CGContextRef)context
{
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

#if 0
- (void)setSegmentNum:(NSInteger)segmentNum
{
    if (segmentNum < 1)
    {
        return;
    }
    
    if (_segmentNum != segmentNum)
    {
        _segmentNum = segmentNum;
        [self updateLines];
    }
}

- (void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
    [self updateLines];
}

- (void)setLineShadowColor:(UIColor *)lineShadowColor
{
    _lineShadowColor = lineShadowColor;
    [self updateLines];
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    if (lineWidth != _lineWidth)
    {
        _lineWidth = lineWidth;
        [self updateLines];
    }
}

- (void)updateLines
{
    NSMutableArray* array = [NSMutableArray array];
    for (UIView* subview in self.subviews)
    {
        if ([subview isKindOfClass:[OLineView class]])
        {
            [array addObject:subview];
            [subview removeFromSuperview];
        }
    }
    
    NSInteger lineNum = _segmentNum - 1;
    while (array.count > lineNum)
    {
        UIView* lastLine = [array lastObject];
        [array removeLastObject];
    }

    while (array.count < lineNum)
    {
        OLineView* lineView = [[OLineView alloc] initWithFrame:CGRectZero];
        [array addObject:lineView];
    }

    CGRect drawingRect = CGRectInset(self.bounds, super.marginX, super.marginY);

    CGFloat startX = drawingRect.origin.x;
    CGFloat endX = startX + drawingRect.size.width;
    
    for (NSInteger i = 0; i < array.count; ++i)
    {
        OLineView* lineView = array[i];
        lineView.lineColor = _lineColor;
        lineView.lineShadowColor = _lineShadowColor;
        lineView.lineShadowOffsetY = _lineShadowOffsetY;
        lineView.lineWidth = _lineWidth;
        
        CGFloat y = drawingRect.size.height * (CGFloat)(i + 1) / (CGFloat)_segmentNum + drawingRect.origin.y;
        float height = lineView.intrinsicContentSize.height;
        lineView.frame = CGRectMake(startX, y, endX - startX, height);
        lineView.layer.opacity = 1.0;

        [self insertSubview:lineView atIndex:0];
    }
}
#endif

@end
