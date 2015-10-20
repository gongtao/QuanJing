//
//  OCleanSearchBar.m
//  TaxiRadar
//
//  Created by Su on 04/15/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OCleanSearchBar.h"

@implementation OCleanSearchBar

- (void)layoutSubviews
{
    [super layoutSubviews];

    for (UIView *subview in self.subviews)
    {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
        {
//            subview.alpha = 0.5;
//            subview.hidden = YES;
            continue;
        }
        
        if ([subview isKindOfClass:NSClassFromString(@"UISegmentedControl")]) {
            subview.alpha = 0.0;
            subview.hidden = YES;
            continue;
        }
    }   
}

@end
