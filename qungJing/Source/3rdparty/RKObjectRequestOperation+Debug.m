#import "RKObjectRequestOperation+Debug.h"

@implementation RKObjectRequestOperation (Debug)

- (void)logResponse
{
#if 1
    DDLogDebug(@"Response: %@", self.HTTPRequestOperation.responseString);
#endif
}

@end