//
//  OWTUser.h
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OWTUserData.h"
#import "OWTUserPrivateInfo.h"
#import "OWTUserAssetsInfo.h"
#import "OWTUserFellowshipInfo.h"
#import "OWTUserAlbumsInfo.h"
#import "OWTUserSubscriptionInfo.h"
#import "OWTImageInfo.h"

@interface OWTUser : NSObject

@property (nonatomic, copy, readonly) NSString* userID;
@property (nonatomic, copy, readonly) NSString* nickname;
@property (nonatomic, copy, readonly) NSString* signature;
@property (nonatomic, copy, readonly) OWTImageInfo* avatarImageInfo;
@property (nonatomic, copy, readonly) UIImage *currentImage;

@property (nonatomic, strong, readonly) OWTUserPrivateInfo* privateInfo;
@property (nonatomic, strong, readonly) OWTUserAssetsInfo* assetsInfo;
@property (nonatomic, strong, readonly) OWTUserFellowshipInfo* fellowshipInfo;
@property (nonatomic, strong, readonly) OWTUserAlbumsInfo* albumsInfo;
@property (nonatomic, strong, readonly) OWTUserSubscriptionInfo* subscriptionInfo;

@property (nonatomic, strong)NSArray *friendListArray;
@property (nonatomic, readonly) NSString* displayName;

- (BOOL)isCurrentUser;
- (BOOL)isBasicInfoAvailable;
- (BOOL)isPublicInfoAvailable;

-(void)setUserID:(NSString *)userID;

-(void)updataNickName:(NSString*)name profileData:(UIImage*)image;

- (BOOL)isFollowingUser:(OWTUser*)user;

-(void)setCurrentImage:(UIImage *)currentImage;

- (BOOL)isOwnerOf:(OWTAsset*)asset;

- (void)mergeWithData:(OWTUserData*)userData;

- (void)mergeWithPrivateInfoData:(OWTUserPrivateInfoData*)privateInfoData;
- (void)mergeWithAssetsInfoData:(OWTUserAssetsInfoData*)assetsInfoData;
- (void)mergeWithSubscriptionInfoData:(OWTUserSubscriptionInfoData*)subscriptionInfoData;
- (void)mergeWithFellowshipInfoData:(OWTUserFellowshipInfoData*)fellowshipInfoData;
- (void)mergeWithAlbumsInfoData:(OWTUserAlbumsInfoData*)albumsInfoData;

@end
