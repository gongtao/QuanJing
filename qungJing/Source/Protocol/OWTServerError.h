#pragma once

@interface OWTServerError : NSObject

@property (nonatomic, assign, readonly) NSInteger code;
@property (nonatomic, copy, readonly) NSString* message;

+ (OWTServerError*)unknownError;
- (NSError*)toNSError;

@end
