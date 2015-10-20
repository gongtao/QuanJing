#pragma once

#import <MapKit/MapKit.h>
#import "OMovableAnno.h"

@interface OMovableAnnoView : MKAnnotationView
{
    __weak MKMapView*  _mapView;
    MKMapPoint lastReportedLocation;
    BOOL        animating;
    BOOL        observingMovement;
    CGPoint    _lastCenter;
}

@property (weak, nonatomic) MKMapView* mapView;

@end
