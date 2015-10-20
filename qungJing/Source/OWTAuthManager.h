#pragma once

@interface OWTAuthManager : NSObject

@property (nonatomic, assign, readonly) BOOL isAuthenticated;
@property (nonatomic, strong, readonly) OWTAccessToken* accessToken;
@property(nonatomic, strong)void (^cancelBlock)(void);


- (void)showAuthViewConWithSuccess:(void(^)())success
                            cancel:(void(^)())cancel;

- (void)authWithUsername:(NSString*)email
             password:(NSString*)password
              success:(void (^)())success
              failure:(void (^)(NSError*))failure;

- (void)authWithSMSCellphone:(NSString*)cellphone
                     success:(void (^)())success
                     failure:(void (^)(NSError*))failure;

- (void)authWithSMSCellphone:(NSString*)cellphone
            verificationCode:(NSString*)verificationCode
                     success:(void (^)())success
                     failure:(void (^)(NSError*))failure;

- (void)registerWithEmail:(NSString*)email
                 password:(NSString*)password
                 nickname:(NSString*)nickname
                  success:(void (^)())success
                  failure:(void (^)(NSError*))failure;

- (void)logout;

@end
