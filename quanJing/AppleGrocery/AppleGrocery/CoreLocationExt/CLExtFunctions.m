#import "CLExtFunctions.h"

BOOL IsValidCoordinate(CLLocationCoordinate2D coord)
{
    if (!CLLocationCoordinate2DIsValid(coord))
    {
        return NO;
    }
    
    if (coord.latitude == 0.0 && coord.longitude == 0.0)
    {
        return NO;
    }
    
    return YES;
}
