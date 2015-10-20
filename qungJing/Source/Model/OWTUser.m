//
//  OWTUser.m
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUser.h"
#import "OWTUserManager.h"
#import "OWTAsset.h"

@implementation OWTUser

-(void)updataNickName:(NSString*)name profileData:(UIImage*)image
{
    _nickname = name;
    _currentImage = image;
}

- (BOOL)isCurrentUser
{
    return (self == GetUserManager().currentUser);
}

- (BOOL)isBasicInfoAvailable
{
    return (_userID != nil && _nickname != nil && _avatarImageInfo != nil);
}

- (BOOL)isPublicInfoAvailable
{
    return _assetsInfo != nil && _fellowshipInfo != nil && _albumsInfo != nil;
}



-(void)setUserID:(NSString *)userID
{
    _userID = userID;
}

- (BOOL)isFollowingUser:(OWTUser*)user
{
    NSString* userID = user.userID;
    if (_fellowshipInfo == nil || _fellowshipInfo.followingUserIDs == nil)
    {
        return NO;
    }
    
    BOOL isFollowing = [_fellowshipInfo.followingUserIDs containsObject:userID];
    return isFollowing;
}

-(void)setCurrentImage:(UIImage *)image
{
    _currentImage = image;
}
- (BOOL)isOwnerOf:(OWTAsset*)asset
{
    if (asset == nil)
    {
        return NO;
    }

    return [_userID caseInsensitiveCompare:asset.ownerUserID] == NSOrderedSame;
}

#pragma - Data Merging


- (void)mergeWithData:(OWTUserData*)userData;
{
    if (_userID == nil)
    {
        _userID = userData.userID;
    }
    else
    {
        if (![_userID isEqualToString:userData.userID])
        {
            return;
        }
    }

    if (userData.nickname != nil)
    {
        _nickname = userData.nickname;
    }
    

    if (userData.signature != nil)
    {
        _signature = userData.signature;
    }

    if (userData.avatarImageInfo != nil)
    {
        _avatarImageInfo = userData.avatarImageInfo;
    
    }
    if (userData.avatarImageInfo != nil)
    {
        _avatarImageInfo = userData.avatarImageInfo;
        
    }
    

    [self mergeWithPrivateInfoData:userData.privateInfoData];
    [self mergeWithAssetsInfoData:userData.assetsInfoData];
    [self mergeWithFellowshipInfoData:userData.fellowshipInfoData];
    [self mergeWithSubscriptionInfoData:userData.subscriptionInfoData];
    [self mergeWithAlbumsInfoData:userData.albumsInfoData];
    
}


- (void)mergeWithPrivateInfoData:(OWTUserPrivateInfoData*)privateInfoData
{
    if (privateInfoData == nil)
    {
        return;
    }
    
    if (_privateInfo == nil)
    {
        _privateInfo = [[OWTUserPrivateInfo alloc] init];
    }
    
    [_privateInfo mergeWithData:privateInfoData];
}

- (void)mergeWithAssetsInfoData:(OWTUserAssetsInfoData*)assetsInfoData
{
    if (assetsInfoData == nil)
    {
        return;
    }
    
    if (_assetsInfo == nil)
    {
        _assetsInfo = [[OWTUserAssetsInfo alloc] init];
    }
    
    [_assetsInfo mergeWithData:assetsInfoData];
}

- (void)mergeWithSubscriptionInfoData:(OWTUserSubscriptionInfoData*)subscriptionInfoData
{
    if (subscriptionInfoData == nil)
    {
        return;
    }
    
    if (_subscriptionInfo == nil)
    {
        _subscriptionInfo = [[OWTUserSubscriptionInfo alloc] init];
    }
    
    [_subscriptionInfo mergeWithData:subscriptionInfoData];
}

- (void)mergeWithFellowshipInfoData:(OWTUserFellowshipInfoData*)fellowshipInfoData
{
    if (fellowshipInfoData == nil)
    {
        return;
    }

    if (_fellowshipInfo == nil)
    {
        _fellowshipInfo = [[OWTUserFellowshipInfo alloc] init];
    }
    
    [_fellowshipInfo mergeWithData:fellowshipInfoData];
}

- (void)mergeWithAlbumsInfoData:(OWTUserAlbumsInfoData*)albumsInfoData
{
    if (albumsInfoData == nil)
    {
        return;
    }
    
    if (_albumsInfo == nil)
    {
        _albumsInfo = [[OWTUserAlbumsInfo alloc] init];
        _albumsInfo.userID = self.userID;
    }

    [_albumsInfo mergeWithData:albumsInfoData];
}

- (NSString*)displayName
{
    if ([self isCurrentUser])
    {
        return @"我";
    }
    else
    {
        if (_nickname != nil)
        {
            return _nickname;
        }
        else
        {
            return @"全景用户";
        }
    }
}

@end
