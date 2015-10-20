//
//  OGradientView.m
//  TaxiRadar
//
//  Created by Su on 04/15/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OGradientView.h"

@implementation OGradientView

+(Class)layerClass
{
    return [CAGradientLayer class];
}

- (NSArray*)colors
{
    return ((CAGradientLayer*)(self.layer)).colors;
}

- (void)setColors:(NSArray*)colors
{
    ((CAGradientLayer*)(self.layer)).colors = colors;
}

@end
