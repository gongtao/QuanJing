//
//  OCircleView.m
//  TaxiRadar
//
//  Created by Su on 04/22/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OCircleView.h"

@implementation OCircleView

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetLineWidth(context, 2.0);

    CGContextSetRGBFillColor(context, 0, 0, 1.0, 1.0);
    CGContextSetRGBStrokeColor(context, 0, 0, 1.0, 1.0);

    CGContextFillEllipseInRect(context, self.bounds);

    CGContextStrokePath(context);
}

@end
