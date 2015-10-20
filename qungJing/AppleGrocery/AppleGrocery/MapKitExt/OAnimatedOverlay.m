//
//  OAnimatedOverlayShape.m
//  YHMapDemo
//
//  Created by Su on 04/22/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OAnimatedOverlay.h"

NSString* kShapeBoundsChangedNotification = @"ShapeBoundsChanged";

@implementation OAnimatedOverlay

- (CLLocationCoordinate2D)coordinate
{
    return _coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    if ((coordinate.latitude != _coordinate.latitude) || (coordinate.longitude != _coordinate.longitude))
    {
        _coordinate = coordinate;
        _isBoundingMapRectDirty = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kShapeBoundsChangedNotification object:self];
    }
}

- (MKMapRect)boundingMapRect
{
    if (_isBoundingMapRectDirty)
    {
        _isBoundingMapRectDirty = NO;
        [self updateRect];
    }
    
    return _boundingMapRect;
}    

- (void)updateRect
{
    [NSException raise:NSInternalInconsistencyException 
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

@end
