#pragma once

#import "OWTUser.h"

@interface OWTUserManager : NSObject

@property (nonatomic, strong, readonly) OWTUser* currentUser;
@property (nonatomic, assign)BOOL ifLoginFail;

- (OWTUser*)userForID:(NSString*)userID;
- (OWTUser*)registerUserData:(OWTUserData*)userData;
- (void)registerUserDatas:(NSArray*)users;
- (NSMutableArray*)registerUserDatasAndReturnUsers:(NSArray*)userDatas;
- (void)logout;

-(void)setCurrentUser:(OWTUser *)currentUser;
// TODO maybe this name is not good enough, should change it
- (void)refreshPublicInfoForUser:(OWTUser*)user
                         success:(void (^)())success
                         failure:(void (^)(NSError*))failure;

- (void)refreshCurrentUserSuccess:(void (^)())success
                          failure:(void (^)(NSError*))failure;

- (void)modifyUser:(OWTUser*)user withDict:(NSDictionary *)params
   updatedNickname:(NSString*)updatedNickname
  updatedSignature:(NSString*)updatedSignature
     updatedAvatar:(UIImage*)updatedAvatar
           success:(void (^)())success
           failure:(void (^)(NSError*))failure;
- (void)modifyUser:(OWTUser*)user
   updatedNickname:(NSString*)updatedNickname
  updatedSignature:(NSString*)updatedSignature
     updatedAvatar:(UIImage*)updatedAvatar
           success:(void (^)())success
           failure:(void (^)(NSError*))failure;

- (void)followUser:(OWTUser*)user
           success:(void (^)())success
           failure:(void (^)(NSError*))failure;

- (void)unfollowUser:(OWTUser*)user
             success:(void (^)())success
             failure:(void (^)(NSError*))failure;

- (void)refreshUserAssets:(OWTUser*)user
                  success:(void (^)())success
                  failure:(void (^)(NSError*))failure;

- (void)loadMoreUserAssets:(OWTUser*)user
                     count:(NSInteger)count
                   success:(void (^)())success
                   failure:(void (^)(NSError*))failure;

#pragma mark - User Liked Assets

- (void)refreshUserLikedAssets:(OWTUser*)user
                       success:(void (^)())success
                       failure:(void (^)(NSError*))failure;

- (void)loadMoreUserLikedAssets:(OWTUser*)user
                          count:(NSInteger)count
                        success:(void (^)())success
                        failure:(void (^)(NSError*))failure;

#pragma mark - User Downloaded Assets

- (void)refreshUserDownloadedAssets:(OWTUser*)user
                       success:(void (^)())success
                       failure:(void (^)(NSError*))failure;

- (void)loadMoreUserDownloadedAssets:(OWTUser*)user
                          count:(NSInteger)count
                        success:(void (^)())success
                        failure:(void (^)(NSError*))failure;

#pragma mark - User Shared Assets

- (void)refreshUserSharedAssets:(OWTUser*)user
                        success:(void (^)())success
                        failure:(void (^)(NSError*))failure;

- (void)loadMoreUserSharedAssets:(OWTUser*)user
                          count:(NSInteger)count
                        success:(void (^)())success
                        failure:(void (^)(NSError*))failure;


- (void)refreshUserFollowingUsers:(OWTUser*)user
                          success:(void (^)())success
                          failure:(void (^)(NSError*))failure;

- (void)loadMoreUserFollowingUsers:(OWTUser*)user
                           success:(void (^)())success
                           failure:(void (^)(NSError*))failure;

- (void)refreshUserFollowerUsers:(OWTUser*)user
                         success:(void (^)())success
                         failure:(void (^)(NSError*))failure;

- (void)loadMoreUserFollowerUsers:(OWTUser*)user
                          success:(void (^)())success
                          failure:(void (^)(NSError*))failure;


#pragma -mark 获取好友列表借口
- (void)getUserFriendByUser:(NSString*)userid
                      success:(void (^)())success
                      failure:(void (^)(NSError*))failure;
#pragma mark - Albums

- (void)createAlbumWithName:(NSString*)albumName
                description:(NSString*)description
                 categoryID:(NSString*)categoryID
                    success:(void (^)())success
                    failure:(void (^)(NSError*))failure;

- (void)modifyAlbumWithID:(NSString*)albumID
              updatedName:(NSString*)updatedName
       updatedDescription:(NSString*)updatedDescription
                  success:(void (^)())success
                  failure:(void (^)(NSError*))failure;

- (void)deleteAlbumWithID:(NSString*)albumID
                  success:(void (^)())success
                  failure:(void (^)(NSError*))failure;

@end
