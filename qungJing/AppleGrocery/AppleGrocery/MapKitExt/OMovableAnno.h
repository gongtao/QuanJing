#pragma once

#import <MapKit/MKPointAnnotation.h>
#define kObjectMovedNotification            @ "Object Moved Notification"

@interface OMovableAnno : MKPointAnnotation

-(void)setCoordinate:(CLLocationCoordinate2D)coordinate;

@end
