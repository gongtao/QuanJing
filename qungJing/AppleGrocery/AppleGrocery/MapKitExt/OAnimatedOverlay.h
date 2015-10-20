#pragma once

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

extern NSString* kShapeBoundsChangedNotification;

@interface OAnimatedOverlay : MKShape <MKOverlay>
{
    CLLocationCoordinate2D _coordinate;
    MKMapRect _boundingMapRect;
    BOOL _isBoundingMapRectDirty;
}

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) MKMapRect boundingMapRect;

- (void)updateRect;

@end
