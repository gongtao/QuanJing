//
//  OTopBottomLineBoxView.m
//  AppleGrocery
//
//  Created by Su on 4/9/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OTopBottomLineBoxView.h"

@implementation OTopBottomLineBoxView

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
    self.backgroundColor = nil;
    self.opaque = NO;

    _fillColor = [UIColor colorWithWhite:1.0 alpha: 0.85];
    _lineColor = [UIColor colorWithWhite:0.3 alpha: 0.85];
    _lineWidth = 0.5;

    _marginX = 0;
    _marginY = 0;
}

- (void)drawRect:(CGRect)rect
{
    CGRect drawingRect = CGRectInset(self.bounds, _marginX, _marginY);

    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    //// Draw Box
    UIBezierPath* boxPath = [UIBezierPath bezierPathWithRect:drawingRect];
    [_fillColor setFill];
    [boxPath fill];

    //// Draw the line
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint:drawingRect.origin];
    [path addLineToPoint:CGPointMake(drawingRect.origin.x + drawingRect.size.width, drawingRect.origin.y)];
    [path moveToPoint:CGPointMake(drawingRect.origin.x, drawingRect.origin.y + drawingRect.size.height)];
    [path addLineToPoint:CGPointMake(drawingRect.origin.x + drawingRect.size.width, drawingRect.origin.y + drawingRect.size.height)];
    path.lineWidth = _lineWidth;
    [_lineColor setStroke];
    [path stroke];

    CGContextRestoreGState(context);
}

@end
