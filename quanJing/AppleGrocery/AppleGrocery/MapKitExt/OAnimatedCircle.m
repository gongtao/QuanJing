#import "OAnimatedCircle.h"

@implementation OAnimatedCircle

+ (OAnimatedCircle *)circleWithCenterCoordinate:(CLLocationCoordinate2D)coord
                                         radius:(CLLocationDistance)radius
{
    OAnimatedCircle* circle = [[OAnimatedCircle alloc] init];
    circle.coordinate = coord;
    circle.radius = radius;

    return circle;
}

- (CLLocationDistance)radius
{
    return _radius;
}

- (void)setRadius:(CLLocationDistance)radius
{
    if (radius != _radius)
    {
        _radius = radius;
        _isBoundingMapRectDirty = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kShapeBoundsChangedNotification object:self];
    }
}

- (void)updateRect
{
    MKMapPoint center = MKMapPointForCoordinate(_coordinate);
    double pointsPerMeter = MKMapPointsPerMeterAtLatitude(_coordinate.latitude);
    double radiusInPoints = pointsPerMeter * _radius;
    double minX = center.x - radiusInPoints;
    double minY = center.y - radiusInPoints;
    double height = radiusInPoints * 2.0;
    double width = radiusInPoints * 2.0;
    _boundingMapRect = MKMapRectMake(minX, minY, width, height);
}

@end
