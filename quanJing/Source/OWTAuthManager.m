#import "OWTAuthManager.h"
#import "OWTUserData.h"
#import "OWTAccessToken.h"
#import "OWTDataManager.h"
#import "OWTServerError.h"
#import "OWTAuthViewCon.h"
#import "OWTAppDelegate.h"
#import "OWTUserInfoEditViewCon.h"
#import "OWTUserManager.h"
#import "HuanXinManager.h"
#import "UIColor+HexString.h"
#import "QuanJingSDK.h"
static NSString* kWTStoreKeyAccessToken = @"WTAccessToken";
static NSString* kWTClientID = @"3ae125d6e9a009a6fcce3f081f4ce5ff";

@interface OWTString : NSObject

@property (nonatomic, copy, readonly) NSString* value;

@end

@implementation OWTString

@end

@interface OWTAuthManager ()

@end

@implementation OWTAuthManager

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    [self load];
    [self setupResponseDescriptors];
}

- (void)setupResponseDescriptors
{
    OWTDataManager* dm = GetDataManager();
    
    RKResponseDescriptor* responseDescriptor;
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:dm.accessTokenMapping
                                                                      method:RKRequestMethodAny
                                                                 pathPattern:nil
                                                                     keyPath:@"accessToken"
                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}

#pragma mark - loading / saving

- (void)load
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSData* data = [defaults objectForKey:kWTStoreKeyAccessToken];
    OWTAccessToken* accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self updateAccessToken:accessToken];
}

//把拿到的token写沙盒
- (void)save
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    if (_accessToken != nil)
    {
        [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:_accessToken] forKey:kWTStoreKeyAccessToken];
    }
    else
    {
        [defaults removeObjectForKey:kWTStoreKeyAccessToken];
    }
    [defaults synchronize];
}

#pragma mark - Authentication

- (BOOL)isAuthenticated
{
   QJPassport *pt=[QJPassport sharedPassport];
    if (pt.isLogin)
    {
        return true;
    }
    else
    {
        AssertTR(_accessToken == nil);
        return false;
    }
}

- (void)authWithUsername:(NSString*)username
                password:(NSString*)password
                 success:(void (^)())success
                 failure:(void (^)(NSError*))failure
{
    // TODO check input parameter validity
    
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om postObject:nil
              path:@"auth/login"
        parameters:@{ @"username" : username,
                      @"password" : password,
                      @"client_id": kWTClientID }
           success:^(RKObjectRequestOperation* o, RKMappingResult* result) {
               [o logResponse];
               
               NSDictionary* resultObjects = result.dictionary;
               OWTServerError* error = resultObjects[@"error"];
               if (error != nil)
               {
                   if (failure != nil)
                   {
                       failure([error toNSError]);
//                       NSLog(@"111111111111%@",[error toNSError].userInfo);
                       [SVProgressHUD showErrorWithStatus:[error toNSError].userInfo[@"message"]];
                   }
                   return;
               }
               
               OWTAccessToken* accessToken = resultObjects[@"accessToken"];
               if (accessToken == nil)
               {
                   if (failure != nil)
                   {
                       failure([[OWTServerError unknownError] toNSError]);
                       [SVProgressHUD showErrorWithStatus:[error toNSError].userInfo[@"message"]];
                   }
                   return;
               }
               
               [self updateAccessToken:accessToken];
               
               if (success != nil)
               {
                   success();
               }
           }
           failure:^(RKObjectRequestOperation* o, NSError* error) {
               [o logResponse];
               if (failure != nil)
               {
                   failure(error);
                   
               }
           }
     ];
}

- (void)authWithSMSCellphone:(NSString*)cellphone
                     success:(void (^)())success
                     failure:(void (^)(NSError*))failure
{
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om postObject:nil
              path:@"auth/sms"
        parameters:@{ @"cellphone" : cellphone,
                      @"client_id": kWTClientID }
           success:^(RKObjectRequestOperation* o, RKMappingResult* result) {
               [o logResponse];
               
               NSDictionary* resultObjects = result.dictionary;
               OWTServerError* error = resultObjects[@"error"];
               if (error != nil)
               {
                   if (failure != nil)
                   {
                       failure([error toNSError]);
                        [SVProgressHUD showErrorWithStatus:[error toNSError].userInfo[@"message"]];
                   }
                   return;
               }
               
               if (success != nil)
               {
                   success();
               }
           }
           failure:^(RKObjectRequestOperation* o, NSError* error) {
               [o logResponse];
               if (failure != nil)
               {
                   failure(error);
                   

               }
           }
     ];
}
//短信验证登陆方式  但输入验证码点解完成按钮 后会在此处响应
- (void)authWithSMSCellphone:(NSString*)cellphone
            verificationCode:(NSString*)verificationCode
                     success:(void (^)())success
                     failure:(void (^)(NSError*))failure
{
    if (cellphone == nil || verificationCode == nil)
    {
        AssertTR(cellphone != nil && verificationCode != nil);
        return;
    }
    
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om postObject:nil
              path:@"auth/sms"
        parameters:@{ @"cellphone" : cellphone,
                      @"verification_code" : verificationCode,
                      @"client_id": kWTClientID }
           success:^(RKObjectRequestOperation* o, RKMappingResult* result) {
               [o logResponse];
               
               NSDictionary* resultObjects = result.dictionary;
               OWTServerError* error = resultObjects[@"error"];
               if (error != nil)
               {
                   if (failure != nil)
                   {
                       failure([error toNSError]);//
                       [SVProgressHUD showErrorWithStatus:[error toNSError].userInfo[@"message"]];
                   }
                   return;
               }
               
               OWTAccessToken* accessToken = resultObjects[@"accessToken"];
               if (accessToken == nil)
               {
                   if (failure != nil)
                   {
                       failure([[OWTServerError unknownError] toNSError]);
                       [SVProgressHUD showErrorWithStatus:[[OWTServerError unknownError] toNSError].userInfo[@"message"]];
                   }
                   return;
               }
               
               [self updateAccessToken:accessToken];
               
               if (success != nil)
               {
                   success();
               }
           }
           failure:^(RKObjectRequestOperation* o, NSError* error) {
               [o logResponse];
               if (failure != nil)
               {
                   failure(error);
               }
           }
     ];
}

- (void)logout
{
    [self updateAccessToken:nil];
    [HuanXinManager logoutHuanxin];
    [GetUserManager() setCurrentUser:nil];

}

- (void)updateAccessToken:(OWTAccessToken*)accessToken
{
    _accessToken = accessToken;
    
    RKObjectManager* om = [RKObjectManager sharedManager];
    
    if (accessToken != nil)
    {
        [om.HTTPClient setDefaultHeader:@"Authorization"
                                  value:[NSString stringWithFormat:@"Bearer %@", _accessToken.tokenValue]];
    }
    else
    {
        [om.HTTPClient clearAuthorizationHeader];
    }
//token写沙盒
    [self save];
}

#pragma mark - Register related

- (void)registerWithEmail:(NSString*)email
                 password:(NSString*)password
                 nickname:(NSString*)nickname
                  success:(void (^)())success
                  failure:(void (^)(NSError*))failure
{
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om postObject:nil
              path:@"auth/register"
        parameters:@{ @"email" : email,
                      @"password" : password,
                      @"nickname" : nickname,
                      @"client_id": kWTClientID }
           success:^(RKObjectRequestOperation* o, RKMappingResult* result) {
               [o logResponse];
               
               NSDictionary* resultObjects = result.dictionary;
               OWTServerError* error = resultObjects[@"error"];
               if (error != nil)
               {
                   if (failure != nil)
                   {
                       failure([error toNSError]);
                   }
                   return;
               }
               
               OWTAccessToken* accessToken = resultObjects[@"accessToken"];
               if (accessToken == nil)
               {
                   if (failure != nil)
                   {
                       failure([[OWTServerError unknownError] toNSError]);
                   }
                   return;
               }
               
               [self updateAccessToken:accessToken];
               
               if (success != nil)
               {
                   success();
               }
           }
           failure:^(RKObjectRequestOperation* o, NSError* error) {
               [o logResponse];
               if (failure != nil)
               {
                   failure(error);
               }
           }
     ];
}

- (void)showAuthViewConWithSuccess:(void(^)())success
                            cancel:(void(^)())cancel
{
    OWTAuthViewCon* authViewCon = [[OWTAuthViewCon alloc] init];
    UINavigationController* navCon = [[UINavigationController alloc] initWithRootViewController:authViewCon];
    navCon.navigationBar.barTintColor=[UIColor colorWithHexString:@"2b2b2b"];
    authViewCon.cancelBlock = ^{
        _cancelBlock();
    };
    authViewCon.cancelFunc = ^{
        if (cancel != nil)
        {
            cancel();
        }
        [navCon dismissViewControllerAnimated:YES completion:nil];
    };
    
    authViewCon.successFunc = ^(BOOL isNewUser) {
        if (isNewUser)
        {
            OWTUserInfoEditViewCon* userInfoEditViewCon = [[OWTUserInfoEditViewCon alloc] initWithNibName:nil bundle:nil];
            userInfoEditViewCon.user = GetUserManager().currentUser;
            [navCon setViewControllers:@[userInfoEditViewCon] animated:YES];
            
            userInfoEditViewCon.cancelAction = ^{
                if (cancel != nil)
                {
                    cancel();
                }
                [navCon dismissViewControllerAnimated:YES completion:nil];
            };
            
            userInfoEditViewCon.doneFunc = ^{
                if (success != nil)
                {
                    success();
                }
                [navCon dismissViewControllerAnimated:YES completion:nil];
            };
        }
        else
        {
            if (success != nil)
            {
                success();
            }
            [navCon dismissViewControllerAnimated:YES completion:nil];
        }
    };
    
    [GetAppDelegate().window.rootViewController presentViewController:navCon
                                                             animated:YES
                                                           completion:nil];
}

@end
