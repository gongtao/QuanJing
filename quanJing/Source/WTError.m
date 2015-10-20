#import "WTError.h"

@implementation NSError (Easy)

+ (NSError*)errorWithCode:(NSInteger)code
{
    return [NSError errorWithDomain:kWTErrorDomain
                               code:code
                           userInfo:nil];
}

@end

NSError* MakeError(EWTErrorCodes code)
{
    return [NSError errorWithCode:(NSInteger)code];
}
