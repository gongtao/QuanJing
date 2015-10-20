#import "OWTUserManager.h"
#import "OWTServerError.h"
#import "OWTDataManager.h"
#import "OWTAuthManager.h"
#import "OWTAssetManager.h"
#import "HuanXinManager.h"
#import "HXChatInitModel.h"
#import "HxNickNameImageModel.h"
@interface OWTUserManager ()
{
    NSMutableDictionary* _usersByID;
    NSString* _accessToken;
}

@end

@implementation OWTUserManager

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
    _usersByID = [NSMutableDictionary dictionaryWithCapacity:1024];
    [self setupResponseDescriptors];
    [self refreshCurrentUserSuccess:nil failure:nil];
}

-(void)setCurrentUser:(OWTUser *)currentUser
{
    _currentUser = currentUser;
}

- (void)setupResponseDescriptors
{
    OWTDataManager* dm = GetDataManager();

    RKResponseDescriptor* responseDescriptor;
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:dm.userMapping
                                                                      method:RKRequestMethodGET | RKRequestMethodPOST
                                                                 pathPattern:nil
                                                                     keyPath:@"user"
                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];

    RKRequestDescriptor* requestDescriptor;
    requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:dm.userMappingInversed
                                                              objectClass:[OWTUserData class]
                                                              rootKeyPath:nil
                                                                   method:RKRequestMethodPOST];
    [[RKObjectManager sharedManager] addRequestDescriptor:requestDescriptor];
}

#pragma mark -

- (OWTUser*)userForID:(NSString*)userID
{
    
//    OWTUser *user =[_usersByID objectForKey:userID];
//    [self refreshPublicInfoForUser:user
//                         success:^{
//                            
//                             
//                             
//                         }
//                         failure:^(NSError* error) {
//                             
//                         }];

    return [_usersByID objectForKey:userID];;
}

- (void)registerUserDatas:(NSArray*)userDatas
{
    for (OWTUserData* userData in userDatas)
    {
        [self registerUserData:userData];
    }
}

- (NSMutableArray*)registerUserDatasAndReturnUsers:(NSArray*)userDatas
{
    NSMutableArray* users = [NSMutableArray array];

    for (OWTUserData* userData in userDatas)
    {
        OWTUser* user = [self registerUserData:userData];
        [users addObject:user];
    }

    return users;
}

//registerUserData 怎么调用
- (OWTUser*)registerUserData:(OWTUserData*)userData
{
    if (userData == nil)
    {
        return nil;
    }
    
    OWTUser* user = [_usersByID objectForKey:userData.userID];
    if (user == nil)
    {
        user = [[OWTUser alloc] init];
        [_usersByID setObject:user forKey:userData.userID];
    }

    [user mergeWithData:userData];
    
    return user;
}

#pragma mark - General

- (void)refreshCurrentUserSuccess:(void (^)())success
                          failure:(void (^)(NSError*))failure
{
    OWTAuthManager* am = GetAuthManager();
    
    if (!am.isAuthenticated)
    {
        if (failure != nil)
        {
            failure(MakeError(kWTErrorAuthFailed));
            return;
        }
    }
    
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om getObjectsAtPath:@"users/me"
              parameters:nil
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
                     
                     OWTUserData* userData = resultObjects[@"user"];
                     if (userData == nil)
                     {
                         if (failure != nil)
                         {
                             failure([[OWTServerError unknownError] toNSError]);
                         }
                         return;
                     }
                     
                     OWTUser* user = [self registerUserData:userData];
                     if (_currentUser == nil)
                     {
                         _currentUser = user;
                         NSString *urlPath =  _currentUser.avatarImageInfo.url;
                         
                         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                             //耗时操作
                             UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlPath]]];
                             
                             if (image != nil) {
                                 //更新数据
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [_currentUser setCurrentImage:image];
                                 });}
                         });
                     }
                     else
                     {
                         AssertTR(_currentUser == user);
                     }

                     [self initHuanXinSDK:user];
                     [self getFirendList:user];

                     NSArray* relatedAssetDatas = resultObjects[@"relatedAssets"];
                     if (relatedAssetDatas == nil)
                     {
                         if (failure != nil)
                         {
                             failure([[OWTServerError unknownError] toNSError]);
                         }
                         return;
                     }
                     [GetAssetManager() registerAssetDatas:relatedAssetDatas];
                     
                     NSArray* relatedUserDatas = resultObjects[@"relatedUsers"];
                     if (relatedUserDatas == nil)
                     {
                         if (failure != nil)
                         {
                             failure([[OWTServerError unknownError] toNSError]);
                         }
                         return;
                     }
                     [GetUserManager() registerUserDatas:relatedUserDatas];

                     if (success != nil)
                     {
                         success();
                     }
                 }
                 failure:^(RKObjectRequestOperation* o, NSError* error) {
                     OWTUserManager* am = GetUserManager();
                     am.ifLoginFail = YES;
                     if (failure != nil)
                     {
                         failure(error);
                     }
                 }];
}

-(void)initHuanXinSDK:(OWTUser*)user
{
    NSArray *array = [HXChatInitModel getCountAndPWDbyMD5];
    NSString *hxUsrId = [array firstObject];
    NSString *password = [array lastObject];
    //初始化 并登陆环信
    if ([[EaseMob sharedInstance].chatManager isLoggedIn]) {
        //就是一个异步的线程
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            //耗时操作
            [HuanXinManager   logoutHuanxin];
            [HuanXinManager sharedTool:hxUsrId passWord:password];
        });
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            //耗时操作
            [HuanXinManager sharedTool:hxUsrId passWord:password];

        });
    }

}

-(void)getFirendList:(OWTUser *)user
{
    //就是一个异步的线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //耗时操作
        
        OWTUserManager* um = GetUserManager();
        __block NSArray * friendsArray = [NSArray array];
        [um getUserFriendByUser:user
                        success:^{
                            
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                        friendsArray = user.friendListArray ;
                            //拿着一组ID，如果本地没有 就去缓存头像
                        [HxNickNameImageModel getAvatarNickNameRequest:friendsArray];
                
                });
                        }
                        failure:^(NSError* error) {
                            
                            // [SVProgressHUD showError:error];
                            //  if (loadMoreDoneFunc != nil)
                            // {
                            //   loadMoreDoneFunc();
                            // }
                        }];

    });


}

-(void)reloginHuanXinSDK
{

}
#pragma -mark 这个接口貌似能实现 获取某个用户的属性
- (void)refreshPublicInfoForUser:(OWTUser*)user
                         success:(void (^)())success
                         failure:(void (^)(NSError*))failure
{
    if (user == nil)
    {
        if (failure != nil)
        {
            failure(MakeError(kWTErrorBadParam));
            return;
        }
    }
    //获取用户信息在URL后追加usrId即可，不需要json格式参数
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om getObjectsAtPath:[NSString stringWithFormat:@"users/%@", user.userID]
              parameters:nil
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

                     OWTUserData* incomingUserData = resultObjects[@"user"];
                     if (incomingUserData == nil)
                     {
                         if (failure != nil)
                         {
                             failure([[OWTServerError unknownError] toNSError]);
                         }
                         return;
                     }

                     [user mergeWithData:incomingUserData];

                     NSArray* relatedAssetDatas = resultObjects[@"relatedAssets"];
                     if (relatedAssetDatas == nil)
                     {
                         if (failure != nil)
                         {
                             failure([[OWTServerError unknownError] toNSError]);
                         }
                         return;
                     }
                     [GetAssetManager() registerAssetDatas:relatedAssetDatas];
                     
                     NSArray* relatedUserDatas = resultObjects[@"relatedUsers"];
                     if (relatedUserDatas == nil)
                     {
                         if (failure != nil)
                         {
                             failure([[OWTServerError unknownError] toNSError]);
                         }
                         return;
                     }
                     [GetUserManager() registerUserDatas:relatedUserDatas];

                     if (success != nil)
                     {
                         success();
                     }
                 }
                 failure:^(RKObjectRequestOperation* o, NSError* error) {
                     if (failure != nil)
                     {
                         failure(error);
                     }
                 }];
}
- (void)modifyUser:(OWTUser*)user withDict:(NSDictionary*)params
   updatedNickname:(NSString*)updatedNickname
  updatedSignature:(NSString*)updatedSignature
     updatedAvatar:(UIImage*)updatedAvatar
           success:(void (^)())success
           failure:(void (^)(NSError*))failure
{
    OWTAuthManager* am = GetAuthManager();
    if (!am.isAuthenticated)
    {
        if (failure != nil)
        {
            failure(MakeError(kWTErrorAuthFailed));
            return;
        }
    }

    NSMutableURLRequest* request;
    RKObjectManager* om = [RKObjectManager sharedManager];
    request = [om multipartFormRequestWithObject:nil
                                          method:RKRequestMethodPOST
                                            path:@"users/update"
                                      parameters:params
                       constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                           if (updatedAvatar != nil)
                           {
                               // TODO maybe resize here
 [formData appendPartWithFileData:UIImageJPEGRepresentation(updatedAvatar, 1)
        name:@"avatar" fileName:@"updated-avatar.png" mimeType:@"image/png"];
                           }}];
    
    RKObjectRequestOperation* operation;
    operation = [om objectRequestOperationWithRequest:request
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
                                                  
        OWTUserData* userData = resultObjects[@"user"];
            if (userData == nil)
                {
                   if (failure != nil)
                    {
                     //failure([[OWTServerError unknownError] toNSError]);
                        success(user);
                                                      }
                            return;
                                                  }
                                                  
                        [user mergeWithData:userData];
                                                  
            if (success != nil)
                {
                    success(user);
                                                  }
                                              }
                failure:^(RKObjectRequestOperation* o, NSError* error) {
                        if (failure != nil)
                {
                    failure(error);
                                  }
                                              }];
    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation];
}

- (void)modifyUser:(OWTUser*)user
   updatedNickname:(NSString*)updatedNickname
  updatedSignature:(NSString*)updatedSignature
     updatedAvatar:(UIImage*)updatedAvatar
           success:(void (^)())success
           failure:(void (^)(NSError*))failure
{
    OWTAuthManager* am = GetAuthManager();
    if (!am.isAuthenticated)
    {
        if (failure != nil)
        {
            failure(MakeError(kWTErrorAuthFailed));
            return;
        }
    }

    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:user.userID forKey:@"user_id"];

    if (updatedNickname != nil)
    {
        [params setObject:updatedNickname forKey:@"nickname"];
    }

    if (updatedSignature != nil)
    {
        [params setObject:updatedSignature forKey:@"signature"];
    }

    NSMutableURLRequest* request;
    RKObjectManager* om = [RKObjectManager sharedManager];
    request = [om multipartFormRequestWithObject:nil
                                          method:RKRequestMethodPOST
                                            path:@"users/me"
                                      parameters:params
                       constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                           if (updatedAvatar != nil)
                           {
                               // TODO maybe resize here
                               [formData appendPartWithFileData:UIImagePNGRepresentation(updatedAvatar)
                                                           name:@"avatar"
                                                       fileName:@"updated-avatar.png"
                                                       mimeType:@"image/png"];
                           }
                       }];
    
    RKObjectRequestOperation* operation;
    operation = [om objectRequestOperationWithRequest:request
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
                                                  
                                                  OWTUserData* userData = resultObjects[@"user"];
                                                  if (userData == nil)
                                                  {
                                                      if (failure != nil)
                                                      {
                                                          failure([[OWTServerError unknownError] toNSError]);
                                                      }
                                                      return;
                                                  }

                                                  [user mergeWithData:userData];

                                                  if (success != nil)
                                                  {
                                                      success(user);
                                                  }
                                              }
                                              failure:^(RKObjectRequestOperation* o, NSError* error) {
                                                  if (failure != nil)
                                                  {
                                                      failure(error);
                                                  }
                                              }];
    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation];
}

#pragma mark - User Assets

- (void)refreshUserAssets:(OWTUser*)user
                  success:(void (^)())success
                  failure:(void (^)(NSError*))failure
{
    
    OWTUserAssetsInfo* assetsInfo = user.assetsInfo;
    NSInteger photoNum = assetsInfo.publicAssetNum;
    if (assetsInfo != nil)
    {
        if (user.isCurrentUser)
        {
            photoNum += assetsInfo.privateAssetNum;
        }
        
        //        NSLog(@"000000000000000000%d",photoNum);
    }
    else
    {
        
    }

    [self fetchUserAssets:user
               startIndex:0
                    count:60
                  dropOld:YES
                  success:success
                  failure:failure];
}

- (void)loadMoreUserAssets:(OWTUser*)user
                     count:(NSInteger)count
                   success:(void (^)())success
                   failure:(void (^)(NSError*))failure
{
    NSInteger startIndex;
    if (user.assetsInfo != nil && user.assetsInfo.assets != nil)
    {
        startIndex = user.assetsInfo.assets.count;
    }
    else
    {
        startIndex = 0;
    }

    [self fetchUserAssets:user
               startIndex:user.assetsInfo.assets.count
                    count:60
                  dropOld:NO
                  success:success
                  failure:failure];
}

- (void)fetchUserAssets:(OWTUser*)user
             startIndex:(NSInteger)startIndex
                  count:(NSInteger)count
                dropOld:(BOOL)dropOld
                success:(void (^)())success
                failure:(void (^)(NSError*))failure
{
    if (!user.isPublicInfoAvailable)
    {
        [self refreshPublicInfoForUser:user
                               success:^{
                                   [self fetchUserAssets:user
                                              startIndex:startIndex
                                                   count:count
                                                 dropOld:dropOld
                                                 success:success
                                                 failure:failure];
                               }
                               failure:^(NSError* error) {
                                   if (failure != nil)
                                   {
                                       failure(error);
                                   }
                               }];
    }
    else
    {
        RKObjectManager* om = [RKObjectManager sharedManager];
        [om getObject:nil
                 path:[NSString stringWithFormat:@"users/%@/assets", user.userID]
           parameters:@{ @"startIndex" : [NSString stringWithFormat:@"%d", startIndex],
                         @"count" : [NSString stringWithFormat:@"%d", count] }
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
                  
                  NSArray* assetDatas = resultObjects[@"assets"];
                  if (assetDatas == nil)
                  {
                      if (failure != nil)
                      {
                          failure(MakeError(kWTErrorGeneral));
                      }
                      return;
                  }
                  NSArray* assets = [GetAssetManager() registerAssetDatasAndReturnAssets:assetDatas];
                  if (dropOld)
                  {
                      user.assetsInfo.assets = [NSMutableOrderedSet orderedSetWithArray:assets];
                  }
                  else
                  {
                      if (user.assetsInfo.assets == nil)
                      {
                          user.assetsInfo.assets = [NSMutableOrderedSet orderedSetWithArray:assets];
                      }
                      else
                      {
                          [user.assetsInfo.assets addObjectsFromArray:assets];
                      }
                  }
                  
                  NSArray* relatedUserDatas = resultObjects[@"relatedUsers"];
                  if (relatedUserDatas == nil)
                  {
                      if (failure != nil)
                      {
                          failure([[OWTServerError unknownError] toNSError]);
                      }
                      return;
                  }
                  [GetUserManager() registerUserDatas:relatedUserDatas];
                  
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
}

#pragma mark - User Liked Assets

- (void)refreshUserLikedAssets:(OWTUser*)user
                       success:(void (^)())success
                       failure:(void (^)(NSError*))failure
{
    [self fetchUserLikedAssets:user
                    startIndex:0
                         count:60
                       dropOld:YES
                       success:success
                       failure:failure];
}

- (void)loadMoreUserLikedAssets:(OWTUser*)user
                          count:(NSInteger)count
                        success:(void (^)())success
                        failure:(void (^)(NSError*))failure
{
    NSInteger startIndex;
    if (user.assetsInfo != nil && user.assetsInfo.likedAssets != nil)
    {
        startIndex = user.assetsInfo.likedAssets.count;
    }
    else
    {
        startIndex = 0;
    }
    
    [self fetchUserLikedAssets:user
                    startIndex:user.assetsInfo.likedAssets.count
                         count:60
                       dropOld:NO
                       success:success
                       failure:failure];
}

- (void)fetchUserLikedAssets:(OWTUser*)user
                  startIndex:(NSInteger)startIndex
                       count:(NSInteger)count
                     dropOld:(BOOL)dropOld
                     success:(void (^)())success
                     failure:(void (^)(NSError*))failure
{
    if (!user.isPublicInfoAvailable)
    {
        [self refreshPublicInfoForUser:user
                               success:^{
                                   [self fetchUserLikedAssets:user
                                                   startIndex:startIndex
                                                        count:count
                                                      dropOld:dropOld
                                                      success:success
                                                      failure:failure];
                               }
                               failure:^(NSError* error) {
                                   if (failure != nil)
                                   {
                                       failure(error);
                                   }
                               }];
    }
    else
    {
        RKObjectManager* om = [RKObjectManager sharedManager];
        [om getObject:nil
                 path:[NSString stringWithFormat:@"users/%@/likes", user.userID]
           parameters:@{ @"startIndex" : [NSString stringWithFormat:@"%d", startIndex],
                         @"count" : [NSString stringWithFormat:@"%d", count] }
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
                  
                  NSArray* assetDatas = resultObjects[@"assets"];
                  if (assetDatas == nil)
                  {
                      if (failure != nil)
                      {
                          failure(MakeError(kWTErrorGeneral));
                      }
                      return;
                  }
                  
                  NSMutableArray* assets = [GetAssetManager() registerAssetDatasAndReturnAssets:assetDatas];
                  if (dropOld)
                  {
                      user.assetsInfo.likedAssets = [NSMutableOrderedSet orderedSetWithArray:assets];
                  }
                  else
                  {
                      if (user.assetsInfo.likedAssets == nil)
                      {
                          user.assetsInfo.likedAssets = [NSMutableOrderedSet orderedSetWithArray:assets];
                      }
                      else
                      {
                          [user.assetsInfo.likedAssets addObjectsFromArray:assets];
                      }
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
}

#pragma mark - User Downloaded Assets

- (void)refreshUserDownloadedAssets:(OWTUser*)user
                            success:(void (^)())success
                            failure:(void (^)(NSError*))failure
{
    [self fetchUserDownloadedAssets:user
                         startIndex:0
                              count:60
                            dropOld:YES
                            success:success
                            failure:failure];
}

- (void)loadMoreUserDownloadedAssets:(OWTUser*)user
                               count:(NSInteger)count
                             success:(void (^)())success
                             failure:(void (^)(NSError*))failure
{
    NSInteger startIndex;
    if (user.assetsInfo != nil && user.assetsInfo.downloadedAssets != nil)
    {
        startIndex = user.assetsInfo.downloadedAssets.count;
    }
    else
    {
        startIndex = 0;
    }
    
    [self fetchUserDownloadedAssets:user
                         startIndex:user.assetsInfo.downloadedAssets.count
                              count:60
                            dropOld:NO
                            success:success
                            failure:failure];
}

- (void)fetchUserDownloadedAssets:(OWTUser*)user
                       startIndex:(NSInteger)startIndex
                            count:(NSInteger)count
                          dropOld:(BOOL)dropOld
                          success:(void (^)())success
                          failure:(void (^)(NSError*))failure
{
    if (!user.isPublicInfoAvailable)
    {
        [self refreshPublicInfoForUser:user
                               success:^{
                                   [self fetchUserDownloadedAssets:user
                                                        startIndex:startIndex
                                                             count:count
                                                           dropOld:dropOld
                                                           success:success
                                                           failure:failure];
                               }
                               failure:^(NSError* error) {
                                   if (failure != nil)
                                   {
                                       failure(error);
                                   }
                               }];
    }
    else
    {
        RKObjectManager* om = [RKObjectManager sharedManager];
        [om getObject:nil
                 path:[NSString stringWithFormat:@"users/%@/downloaded", user.userID]
           parameters:@{ @"startIndex" : [NSString stringWithFormat:@"%d", startIndex],
                         @"count" : [NSString stringWithFormat:@"%d", count] }
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

                  NSArray* assetDatas = resultObjects[@"assets"];
                  if (assetDatas == nil)
                  {
                      if (failure != nil)
                      {
                          failure(MakeError(kWTErrorGeneral));
                      }
                      return;
                  }
                  
                  NSMutableArray* assets = [GetAssetManager() registerAssetDatasAndReturnAssets:assetDatas];
                  if (dropOld)
                  {
                      user.assetsInfo.downloadedAssets = [NSMutableOrderedSet orderedSetWithArray:assets];
                  }
                  else
                  {
                      if (user.assetsInfo.downloadedAssets == nil)
                      {
                          user.assetsInfo.downloadedAssets = [NSMutableOrderedSet orderedSetWithArray:assets];
                      }
                      else
                      {
                          [user.assetsInfo.downloadedAssets addObjectsFromArray:assets];
                      }
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
}

#pragma mark - User Shared Assets

- (void)refreshUserSharedAssets:(OWTUser*)user
                        success:(void (^)())success
                        failure:(void (^)(NSError*))failure
{
    [self fetchUserSharedAssets:user
                     startIndex:0
                          count:60
                        dropOld:YES
                        success:success
                        failure:failure];
}

- (void)loadMoreUserSharedAssets:(OWTUser*)user
                           count:(NSInteger)count
                         success:(void (^)())success
                         failure:(void (^)(NSError*))failure
{
    NSInteger startIndex;
    if (user.assetsInfo != nil && user.assetsInfo.sharedAssets != nil)
    {
        startIndex = user.assetsInfo.sharedAssets.count;
    }
    else
    {
        startIndex = 0;
    }
    
    [self fetchUserSharedAssets:user
                     startIndex:user.assetsInfo.sharedAssets.count
                          count:60
                        dropOld:NO
                        success:success
                        failure:failure];
}

- (void)fetchUserSharedAssets:(OWTUser*)user
                   startIndex:(NSInteger)startIndex
                        count:(NSInteger)count
                      dropOld:(BOOL)dropOld
                      success:(void (^)())success
                      failure:(void (^)(NSError*))failure
{
    if (!user.isPublicInfoAvailable)
    {
        [self refreshPublicInfoForUser:user
                               success:^{
                                   [self fetchUserSharedAssets:user
                                                    startIndex:startIndex
                                                         count:count
                                                       dropOld:dropOld
                                                       success:success
                                                       failure:failure];
                               }
                               failure:^(NSError* error) {
                                   if (failure != nil)
                                   {
                                       failure(error);
                                   }
                               }];
    }
    else
    {
        RKObjectManager* om = [RKObjectManager sharedManager];
        [om getObject:nil
                 path:[NSString stringWithFormat:@"users/%@/lightbox", user.userID]
           parameters:@{ @"startIndex" : [NSString stringWithFormat:@"%d", startIndex],
                         @"count" : [NSString stringWithFormat:@"%d", count] }
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
                  
                  NSArray* assetDatas = resultObjects[@"assets"];
                  if (assetDatas == nil)
                  {
                      if (failure != nil)
                      {
                          failure(MakeError(kWTErrorGeneral));
                      }
                      return;
                  }
                  
                  NSMutableArray* assets = [GetAssetManager() registerAssetDatasAndReturnAssets:assetDatas];
                  if (dropOld)
                  {
                      user.assetsInfo.sharedAssets = [NSMutableOrderedSet orderedSetWithArray:assets];
                  }
                  else
                  {
                      if (user.assetsInfo.sharedAssets == nil)
                      {
                          user.assetsInfo.sharedAssets = [NSMutableOrderedSet orderedSetWithArray:assets];
                      }
                      else
                      {
                          [user.assetsInfo.sharedAssets addObjectsFromArray:assets];
                      }
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
}

#pragma mark - Fellowship

- (void)followUser:(OWTUser*)user
           success:(void (^)())success
           failure:(void (^)(NSError*))failure
{
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om postObject:nil
              path:[NSString stringWithFormat:@"users/%@/followings", _currentUser.userID]
        parameters:@{ @"action" : @"follow",
                      @"following_user_id": user.userID }
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
               
               OWTUserFellowshipInfo* fellowshipInfo = _currentUser.fellowshipInfo;
               fellowshipInfo.followingNum = fellowshipInfo.followingNum + 1;
               [fellowshipInfo.followingUserIDs addObject:user.userID];
               
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

- (void)unfollowUser:(OWTUser*)user
             success:(void (^)())success
             failure:(void (^)(NSError*))failure
{
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om postObject:nil
              path:[NSString stringWithFormat:@"users/%@/followings", _currentUser.userID]
        parameters:@{ @"action" : @"unfollow",
                      @"following_user_id": user.userID }
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
               
               OWTUserFellowshipInfo* fellowshipInfo = _currentUser.fellowshipInfo;
               fellowshipInfo.followingNum = fellowshipInfo.followingNum - 1;
               if (fellowshipInfo.followingNum < 0)
               {
                   fellowshipInfo.followingNum = 0;
               }
               [fellowshipInfo.followingUserIDs removeObject:user.userID];
               fellowshipInfo.followingUsers = nil;
               
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

#pragma mark - Fellowing Users

- (void)refreshUserFollowingUsers:(OWTUser*)user
                          success:(void (^)())success
                          failure:(void (^)(NSError*))failure
{
    if (!user.isPublicInfoAvailable)
    {
        [self refreshPublicInfoForUser:user
                               success:^{
                                   [self fetchUserFollowingUsers:user startIndex:0 count:50 dropOld:YES success:success failure:failure];
                               }
                               failure:^(NSError* error) {
                                   if (failure != nil)
                                   {
                                       failure(error);
                                   }
                               }];
    }
    else
    {
        [self fetchUserFollowingUsers:user startIndex:0 count:50 dropOld:YES success:success failure:failure];
    }
}

- (void)loadMoreUserFollowingUsers:(OWTUser*)user
                           success:(void (^)())success
                           failure:(void (^)(NSError*))failure
{
    
    if (!user.isPublicInfoAvailable)
    {
        [self refreshPublicInfoForUser:user
                               success:^{
                                   NSInteger startIndex = user.fellowshipInfo.followingUsers.count;
                                   [self fetchUserFollowingUsers:user startIndex:startIndex count:50 dropOld:NO success:success failure:failure];
                               }
                               failure:^(NSError* error) {
                                   if (failure != nil)
                                   {
                                       failure(error);
                                   }
                               }];
    }
    else
    {
        NSInteger startIndex = user.fellowshipInfo.followingUsers.count;
        [self fetchUserFollowingUsers:user startIndex:startIndex count:50 dropOld:NO success:success failure:failure];
    }
}
//
- (void)fetchUserFollowingUsers:(OWTUser*)user
                     startIndex:(NSInteger)startIndex
                          count:(NSInteger)count
                        dropOld:(BOOL)dropOld
                        success:(void (^)())success
                        failure:(void (^)(NSError*))failure
{
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om getObject:nil
             path:[NSString stringWithFormat:@"users/%@/followings", user.userID]
       parameters:@{ @"startIndex" : [NSString stringWithFormat:@"%d", startIndex],
                     @"count" : [NSString stringWithFormat:@"%d", count] }
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

              NSArray* userDatas = resultObjects[@"users"];
              if (userDatas == nil)
              {
                  if (failure != nil)
                  {
                      failure(MakeError(kWTErrorGeneral));
                  }
                  return;
              }

              NSMutableArray* users = [self registerUserDatasAndReturnUsers:userDatas];

              if (dropOld)
              {
                  user.fellowshipInfo.followingUsers = [NSMutableOrderedSet orderedSetWithArray:users];
              }
              else
              {
                  if (user.fellowshipInfo.followingUsers == nil)
                  {
                      user.fellowshipInfo.followingUsers = [NSMutableOrderedSet orderedSetWithArray:users];
                  }
                  else
                  {
                      [user.fellowshipInfo.followingUsers addObjectsFromArray:users];
                  }
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

#pragma mark - Follower Users

- (void)refreshUserFollowerUsers:(OWTUser*)user
                         success:(void (^)())success
                         failure:(void (^)(NSError*))failure
{
    if (!user.isPublicInfoAvailable)
    {
        [self refreshPublicInfoForUser:user
                               success:^{
                                   [self fetchUserFollowerUsers:user startIndex:0 count:50 dropOld:YES success:success failure:failure];
                               }
                               failure:^(NSError* error) {
                                   if (failure != nil)
                                   {
                                       failure(error);
                                   }
                               }];
    }
    else
    {
        [self fetchUserFollowerUsers:user startIndex:0 count:60 dropOld:YES success:success failure:failure];
    }
}

- (void)loadMoreUserFollowerUsers:(OWTUser*)user
                          success:(void (^)())success
                          failure:(void (^)(NSError*))failure
{
    
    if (!user.isPublicInfoAvailable)
    {
        [self refreshPublicInfoForUser:user
                               success:^{
                                   NSInteger startIndex = user.fellowshipInfo.followerUsers.count;
                                   [self fetchUserFollowerUsers:user startIndex:startIndex count:60 dropOld:NO success:success failure:failure];
                               }
                               failure:^(NSError* error) {
                                   if (failure != nil)
                                   {
                                       failure(error);
                                   }
                               }];
    }
    else
    {
        NSInteger startIndex = user.fellowshipInfo.followerUsers.count;
        [self fetchUserFollowerUsers:user startIndex:startIndex count:60 dropOld:NO success:success failure:failure];
    }
}

- (void)fetchUserFollowerUsers:(OWTUser*)user
                    startIndex:(NSInteger)startIndex
                         count:(NSInteger)count
                       dropOld:(BOOL)dropOld
                       success:(void (^)())success
                       failure:(void (^)(NSError*))failure
{
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om getObject:nil
             path:[NSString stringWithFormat:@"users/%@/followers", user.userID]
       parameters:@{ @"startIndex" : [NSString stringWithFormat:@"%d", startIndex],
                     @"count" : [NSString stringWithFormat:@"%d", count] }
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
              
              NSArray* followerUserDatas = resultObjects[@"users"];
              if (followerUserDatas == nil)
              {
                  if (failure != nil)
                  {
                      failure(MakeError(kWTErrorGeneral));
                  }
                  return;
              }

              NSMutableArray* users = [self registerUserDatasAndReturnUsers:followerUserDatas];

              if (dropOld)
              {
                  user.fellowshipInfo.followerUsers = [NSMutableOrderedSet orderedSetWithArray:users];
              }
              else
              {
                  if (user.fellowshipInfo.followerUsers == nil)
                  {
                      user.fellowshipInfo.followerUsers = [NSMutableOrderedSet orderedSetWithArray:users];
                      
                  }
                  else
                  {
                      [user.fellowshipInfo.followerUsers addObjectsFromArray:users];
                  }
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

#pragma -mark 获取好友列表
- (void)getUserFriendByUser:(OWTUser*)user
                       success:(void (^)())success
                       failure:(void (^)(NSError*))failure
{
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om getObject:nil
             path:[NSString stringWithFormat:@"users/%@/friends", user.userID]
       parameters:nil
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
              
              NSArray* followerUserDatas = resultObjects[@"users"];
              if (followerUserDatas == nil)
              {
                  if (failure != nil)
                  {
                      failure(MakeError(kWTErrorGeneral));
                  }
                  return;
              }
              
              NSMutableArray* users = [self registerUserDatasAndReturnUsers:followerUserDatas];
              user.friendListArray= users;
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


#pragma mark - Albums

- (void)createAlbumWithName:(NSString*)albumName
                description:(NSString*)description
                 categoryID:(NSString*)categoryID
                    success:(void (^)())success
                    failure:(void (^)(NSError*))failure
{
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om postObject:nil
              path:[NSString stringWithFormat:@"users/%@/albums", _currentUser.userID]
        parameters:@{ @"action" : @"create",
                      @"name" : albumName,
                      @"description": description,
                      @"category_id": categoryID }
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
               
               OWTUserAlbumsInfoData* albumsInfoData = resultObjects[@"albumsInfo"];
               if (albumsInfoData == nil)
               {
                   if (failure != nil)
                   {
                       failure(MakeError(kWTErrorGeneral));
                   }
                   return;
               }
               
               [_currentUser mergeWithAlbumsInfoData:albumsInfoData];
               
               NSArray* relatedAssetDatas = resultObjects[@"relatedAssets"];
               if (relatedAssetDatas == nil)
               {
                   if (failure != nil)
                   {
                       failure([[OWTServerError unknownError] toNSError]);
                   }
                   return;
               }
               [GetAssetManager() registerAssetDatas:relatedAssetDatas];

               NSArray* relatedUserDatas = resultObjects[@"relatedUsers"];
               if (relatedUserDatas == nil)
               {
                   if (failure != nil)
                   {
                       failure([[OWTServerError unknownError] toNSError]);
                   }
                   return;
               }
               [GetUserManager() registerUserDatas:relatedUserDatas];

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

- (void)modifyAlbumWithID:(NSString*)albumID
              updatedName:(NSString*)updatedName
       updatedDescription:(NSString*)updatedDescription
                  success:(void (^)())success
                  failure:(void (^)(NSError*))failure
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    params[@"action"] = @"modify";
    
    if (updatedName != nil)
    {
        params[@"name"] = updatedName;
    }
    
    if (updatedDescription != nil)
    {
        params[@"description"] = updatedDescription;
    }

    RKObjectManager* om = [RKObjectManager sharedManager];
    [om postObject:nil
              path:[NSString stringWithFormat:@"users/%@/albums/%@", _currentUser.userID, albumID]
        parameters:params
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
               
               OWTUserAlbumsInfoData* albumsInfoData = resultObjects[@"albumsInfo"];
               if (albumsInfoData == nil)
               {
                   if (failure != nil)
                   {
                       failure(MakeError(kWTErrorGeneral));
                   }
                   return;
               }
               [_currentUser mergeWithAlbumsInfoData:albumsInfoData];

               NSArray* relatedAssetDatas = resultObjects[@"relatedAssets"];
               if (relatedAssetDatas == nil)
               {
                   if (failure != nil)
                   {
                       failure([[OWTServerError unknownError] toNSError]);
                   }
                   return;
               }
               [GetAssetManager() registerAssetDatas:relatedAssetDatas];
               
               NSArray* relatedUserDatas = resultObjects[@"relatedUsers"];
               if (relatedUserDatas == nil)
               {
                   if (failure != nil)
                   {
                       failure([[OWTServerError unknownError] toNSError]);
                   }
                   return;
               }
               [GetUserManager() registerUserDatas:relatedUserDatas];

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

- (void)deleteAlbumWithID:(NSString*)albumID
                  success:(void (^)())success
                  failure:(void (^)(NSError*))failure
{
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om postObject:nil
              path:[NSString stringWithFormat:@"users/%@/albums/%@", _currentUser.userID, albumID]
        parameters:@{ @"action": @"delete" }
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

               OWTUserAlbumsInfoData* albumsInfoData = resultObjects[@"albumsInfo"];
               if (albumsInfoData == nil)
               {
                   if (failure != nil)
                   {
                       failure(MakeError(kWTErrorGeneral));
                   }
                   return;
               }
               [_currentUser mergeWithAlbumsInfoData:albumsInfoData];
               
               NSArray* relatedAssetDatas = resultObjects[@"relatedAssets"];
               if (relatedAssetDatas == nil)
               {
                   if (failure != nil)
                   {
                       failure([[OWTServerError unknownError] toNSError]);
                   }
                   return;
               }
               [GetAssetManager() registerAssetDatas:relatedAssetDatas];
               
               NSArray* relatedUserDatas = resultObjects[@"relatedUsers"];
               if (relatedUserDatas == nil)
               {
                   if (failure != nil)
                   {
                       failure([[OWTServerError unknownError] toNSError]);
                   }
                   return;
               }
               [GetUserManager() registerUserDatas:relatedUserDatas];
               
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

#pragma mark -

- (void)logout
{
    [_usersByID removeObjectForKey:_currentUser.userID];
    _currentUser = nil;
}

@end
