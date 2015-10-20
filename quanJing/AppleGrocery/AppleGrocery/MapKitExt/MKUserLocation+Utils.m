//
//  MKUserLocation+Utils.m
//  TaxiRadar
//
//  Created by Su on 04/24/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MKUserLocation+Utils.h"

@implementation MKUserLocation (Utils)

- (NSString*)toString
{
    return [NSString stringWithFormat:@"[UserLocation@(%f, %f), Updating: %s]", self.coordinate.latitude, self.coordinate.longitude, self.isUpdating ? "YES" : "NO"];
}

@end
