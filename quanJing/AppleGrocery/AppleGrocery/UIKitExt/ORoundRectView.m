//
//  ORoundCornerView.m
//  Weitu
//
//  Created by Su on 3/29/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "ORoundRectView.h"

@implementation ORoundRectView

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
    self.backgroundColor = nil;
    self.opaque = NO;
    _fillColor=[UIColor clearColor];
//    _fillColor = [UIColor colorWithWhite:1.0 alpha: 0.85];
    _cornerRadius = 5;
    _shadowOffset = CGSizeMake(0.0, 1.0);
    _shadowBlurRadius = 1.0;
//    _shadowColor = [UIColor colorWithWhite:0.6 alpha:0.75];

    _marginY = abs(_shadowOffset.height) + _shadowBlurRadius;
    _marginX = _marginY;
}

- (void)setFillColor:(UIColor *)fillColor
{
    _fillColor = fillColor;
    [self setNeedsDisplay];
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    if (cornerRadius != _cornerRadius)
    {
        _cornerRadius = cornerRadius;
        [self setNeedsDisplay];
    }
}

- (void)setMarginX:(CGFloat)marginX
{
    if (marginX != _marginX)
    {
        _marginX = marginX;
        [self setNeedsDisplay];
    }
}

- (void)setMarginY:(CGFloat)marginY
{
    if (marginY != _marginY)
    {
        _marginY = marginY;
        [self setNeedsDisplay];
    }
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
    if (!CGSizeEqualToSize(shadowOffset, _shadowOffset))
    {
        _shadowOffset = shadowOffset;
        [self setNeedsDisplay];
    }
}

- (void)setShadowBlurRadius:(CGFloat)shadowBlurRadius
{
    if (shadowBlurRadius != _shadowBlurRadius)
    {
        _shadowBlurRadius = shadowBlurRadius;
        [self setNeedsDisplay];
    }
}

- (void)setShadowColor:(UIColor *)shadowColor
{
    _shadowColor = shadowColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGRect drawingRect = CGRectInset(self.bounds, _marginX, _marginY);

    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    //// Rounded Rectangle Drawing
    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: drawingRect cornerRadius: _cornerRadius];

    //// Draw Box
    [_fillColor setFill];
    [roundedRectanglePath fill];
    CGContextRestoreGState(context);

    //// Draw Shadow
    if (_shadowColor != nil)
    {
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, _shadowOffset, _shadowBlurRadius, _shadowColor.CGColor);
        CGRect boundingRect = CGContextGetClipBoundingBox(context);
        CGContextAddRect(context, boundingRect);
        CGContextAddPath(context, roundedRectanglePath.CGPath);
        CGContextEOClip(context);
        [_fillColor setFill];
        [roundedRectanglePath fill];
        CGContextRestoreGState(context);
    }
}

@end
