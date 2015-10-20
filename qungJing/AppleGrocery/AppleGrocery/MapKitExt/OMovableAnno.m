#import "OMovableAnno.h"

@implementation OMovableAnno

-(void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    [super setCoordinate:coordinate];
    [[NSNotificationCenter defaultCenter] postNotificationName:kObjectMovedNotification object:self];
}

@end

