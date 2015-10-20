#import "OWTAccessToken.h"

@implementation OWTAccessToken

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_tokenValue forKey:@"tokenValue"];
    [encoder encodeObject:[NSNumber numberWithInteger:_expiresIn] forKey:@"expiresIn"];
    [encoder encodeObject:_creationTime forKey:@"creationTime"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init]))
    {
        _tokenValue = [decoder decodeObjectForKey:@"tokenValue"];
        _expiresIn = [[decoder decodeObjectForKey:@"expiresIn"] integerValue];
        _creationTime = [decoder decodeObjectForKey:@"creationTime"];
    }
    return self;
}

@end
