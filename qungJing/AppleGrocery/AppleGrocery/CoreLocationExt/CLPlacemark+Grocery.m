//
//  CLPlacemark+Grocery.m
//  Lego
//
//  Created by Bing SU on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CLPlacemark+Grocery.h"

@implementation CLPlacemark (Lego)

- (NSString*)shortAddress
{
    NSMutableString* address = [[NSMutableString alloc] init];
    
    if (self.subLocality != nil)
    {
        [address appendString:self.subLocality];
    }
    
    if (self.thoroughfare != nil)
    {
        [address appendString:self.thoroughfare];
    }
    
    if (self.subThoroughfare != nil)
    {
        [address appendString:self.subThoroughfare];
    }
    
    if ([address length] <= 10)
    {
        if (self.locality != nil)
        {
            [address insertString:self.locality atIndex:0];
        }
    }
    
    return address;
}

@end
