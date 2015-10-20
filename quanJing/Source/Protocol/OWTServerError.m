#import "OWTServerError.h"

static const NSInteger kWTServerErrorCodeUnknown = -1000;
static NSString* kWTServerErrorMessageUnkown = @"Unknown server error.";

@implementation OWTServerError

+ (OWTServerError*)unknownError
{
    static OWTServerError* error;

    if (error == nil)
    {
        error = [[OWTServerError alloc] initWithCode:kWTServerErrorCodeUnknown message:kWTServerErrorMessageUnkown];
    }

    return error;
}

- (id)initWithCode:(NSInteger)code message:(NSString*)message
{
    self = [super init];
    if (self != nil)
    {
        _code = code;
        _message = message;
    }
    return self;
}

- (NSError*)toNSError
{
    return [[NSError alloc] initWithDomain:@"com.weitu"
                                      code:_code
                                  userInfo:@{@"message": _message}];
}

@end
