//
//  OCrossHair.m
//  TaxiRadar
//
//  Created by Su on 04/14/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OCrossHair.h"

@implementation OCrossHair

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextSetStrokeColorWithColor(ctx, [[UIColor grayColor] CGColor]);

    CGFloat dashes[] = {3, 2};

    CGContextSetLineDash(ctx, 0.0, dashes, 2);
    CGContextSetLineWidth(ctx, 0.5);
    
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect) + 5, CGRectGetMidY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect) - 5, CGRectGetMidY(rect));
    
    CGContextStrokePath(ctx);
}

@end
