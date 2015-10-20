#pragma once

#import <MapKit/MapKit.h>

static inline
BOOL CLLocationCoordinate2DEquals(CLLocationCoordinate2D coord1, CLLocationCoordinate2D coord2)
{
    if (coord1.latitude == coord2.latitude && coord1.longitude == coord2.longitude)
    {
        return YES;
    }
    
    return NO;
}