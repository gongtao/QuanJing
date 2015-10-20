//
//  ORoundRectLineView.m
//  AppleGrocery
//
//  Created by Su on 6/10/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "ORoundRectLineView.h"
#import "UIBezierPath+IOS7RoundedRect.h"

@implementation ORoundRectLineView

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

    _cornerRadius = 5;
    _marginX = 0;
    _marginY = 0;
    _strokeColor = [UIColor blackColor];
    _lineWidth = 0.5;
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

- (void)drawRect:(CGRect)rect
{
    CGFloat marginX = _marginX + _lineWidth;
    CGFloat marginY = _marginY + _lineWidth;
    CGRect drawingRect = CGRectInset(self.bounds, marginX, marginY);

    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    CGContextSetLineWidth(context, _lineWidth);
    [_strokeColor setStroke];

    //// Rounded Rectangle Drawing
    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect:drawingRect cornerRadius:_cornerRadius];
    //// Draw Box
    [roundedRectanglePath stroke];

    CGContextRestoreGState(context);
}

@end
