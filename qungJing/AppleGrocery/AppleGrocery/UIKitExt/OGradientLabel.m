//
//  OGradientLabel.m
//  TaxiRadar
//
//  Created by Su on 04/16/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OGradientLabel.h"

@implementation OGradientLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _gradientLayer = [[OGradientView alloc] initWithFrame:self.bounds];
        _gradientLayer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_gradientLayer];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _gradientLayer = [[OGradientView alloc] initWithFrame:self.bounds];
        _gradientLayer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_gradientLayer];
    }

    return self;
}

- (NSArray*)colors
{
    return _gradientLayer.colors;
}

- (void)setColors:(NSArray*)colors
{
    _gradientLayer.colors = colors;
}

- (void)layoutSubviews
{
    _gradientLayer.frame = self.bounds;
}

@end
