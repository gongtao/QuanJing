#pragma once

#import "OWTUserAssetsInfoData.h"
#import "OWTUserFellowshipInfoData.h"
#import "OWTUserAlbumsInfoData.h"
#import "OWTUserSubscriptionInfoData.h"
#import "OWTUserPrivateInfoData.h"
#import "OWTImageInfo.h"
@interface OWTUserData : NSObject

@property (nonatomic, copy) NSString* userID;
@property (nonatomic, copy) NSString* nickname;
@property (nonatomic, copy) NSString* signature;
@property(nonatomic,copy)NSString *Fans;
@property (nonatomic, strong) OWTImageInfo* avatarImageInfo;

@property (nonatomic, strong) OWTUserPrivateInfoData* privateInfoData;

@property (nonatomic, strong) OWTUserAssetsInfoData* assetsInfoData;
@property (nonatomic, strong) OWTUserFellowshipInfoData* fellowshipInfoData;
@property (nonatomic, strong) OWTUserAlbumsInfoData* albumsInfoData;
@property (nonatomic, strong) OWTUserSubscriptionInfoData* subscriptionInfoData;


@end
