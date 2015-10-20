#pragma once

#import <MapKit/MapKit.h>
#import "OAnimatedOverlay.h"

@interface OAnimatedCircle : OAnimatedOverlay
{
    CLLocationDistance _radius;
}

@property (assign, nonatomic) CLLocationDistance radius;

+ (OAnimatedCircle *)circleWithCenterCoordinate:(CLLocationCoordinate2D)coord
                                         radius:(CLLocationDistance)radius;

@end
