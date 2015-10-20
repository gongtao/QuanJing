#import "OMovableAnnoView.h"

#import <Foundation/NSNotification.h>

#define POSITIONKEY @"positionAnimation"
#define BOUNDSKEY @"boundsAnimation"

@implementation OMovableAnnoView

@synthesize mapView = _mapView;

- (void)setAnnotation:(id <MKAnnotation>)anno
{
    if (anno)
    {
        if (!observingMovement)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didMoveAnnotation:) name:kObjectMovedNotification object:anno];
            observingMovement = YES;
        }
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }

    [super setAnnotation : anno];
}

- (void)didMoveAnnotation:(NSNotification*)notification
{
    //	if ([self.layer animationForKey:POSITIONKEY] != nil) {
    //		//attempt to add animation while another is still running. ignore this and let the previous animation finish.
    //		return;
    //	}

    id<MKAnnotation> anno = (id<MKAnnotation>)[notification object];
    lastReportedLocation = MKMapPointForCoordinate(anno.coordinate);
    [self performSelectorOnMainThread:@selector(setPosition:) withObject:[NSValue valueWithPointer:&lastReportedLocation] waitUntilDone:YES];
}

-(void)setPosition:(id)posValue
{
    if (_mapView == nil)
    {
        return;
    }

    //extract the mapPoint from this dummy (wrapper) CGPoint struct
    MKMapPoint mapPoint = *(MKMapPoint*)[(NSValue*) posValue pointerValue];

    //now properly convert this mapPoint to CGPoint
    CGPoint toPos;
    CGFloat zoomFactor = _mapView.visibleMapRect.size.width / _mapView.bounds.size.width;
    toPos.x = mapPoint.x / zoomFactor;
    toPos.y = mapPoint.y / zoomFactor;

    if (!CGPointEqualToPoint(_lastCenter, toPos))
    {
        _lastCenter = toPos;
        [UIView animateWithDuration:0.3
                         animations:^(void) {
                             self.center = toPos;
                         }];
    }
}

@end
