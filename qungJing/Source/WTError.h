#pragma once

#ifdef __OBJC__

@interface NSError (Easy)

+ (NSError*)errorWithCode:(NSInteger)errorCode;

@end


#import "WTConstants.h"

NSError* MakeError(EWTErrorCodes errorCode);

#endif
