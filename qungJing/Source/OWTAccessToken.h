#pragma once

@interface OWTAccessToken : NSObject<NSCoding>

@property (nonatomic, copy, readonly) NSString* tokenValue;
@property (nonatomic, assign, readonly) NSInteger expiresIn;
@property (nonatomic, strong, readonly) NSDate* creationTime;
@property (nonatomic, assign, readonly) BOOL isNewUser;

@end
