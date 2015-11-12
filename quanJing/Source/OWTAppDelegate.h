//
//  OAppDelegate.h
//  Weitu
//
//  Created by Su on 3/8/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXLoginStatus.h"
#import "OQJNavCon.h"
@class OWTMainViewCon;
@interface OWTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow * window;

@property (strong, nonatomic, readonly) OWTGlobalThemer * themer;
@property (strong, nonatomic, readonly) OWTFeedManager * feedManager;
@property (strong, nonatomic, readonly) OWTDataManager * dataManager;
@property (strong, nonatomic, readonly) OWTUserManager * userManager;
@property (strong, nonatomic, readonly) OWTAuthManager * authManager;
@property (strong, nonatomic, readonly) OWTCategoryManager * categoryManager;
//
@property (strong, nonatomic, readonly) OWTCategoryManagerlife * categoryManagerlife;
@property (strong, nonatomic, readonly) OWTCategoryManagerbaike * categoryManagerbaike;

@property (strong, nonatomic, readonly) OWTCategoryManagerlvyou * categoryManagerlvyou;
@property (strong, nonatomic, readonly) OWTCategoryManagerlvyouinternational * categoryManagerlvyouinternational;

@property (strong, nonatomic, readonly) OWTCategoryManagershishang * categoryManagershishang;
@property (strong, nonatomic, readonly) OWTCategoryManagerjiaju * categoryManagerjiaju;
@property (strong, nonatomic, readonly) OWTCategoryManagerqiche * categoryManagerqiche;
@property (strong, nonatomic, readonly) OWTCategoryManagermeishi * categoryManagermeishi;

//
@property (strong, nonatomic, readonly) OWTAssetManager * assetManager;
@property (strong, nonatomic, readonly) OWTActivityManager * activityManager;
@property (strong, nonatomic, readonly) OWTRecommendationManager * recommendationManager;
@property (strong, nonatomic, readonly) OWTRecommendationManager1 * recommendationManager1;
@property (strong, nonatomic, readonly) OWTSearchManager * searchManager;
@property (nonatomic, strong) OWTMainViewCon * mainViewCon;
// 保存 环信是否正确的初始化和登录
@property (strong, nonatomic) HXLoginStatus * hxStatus;
@property (strong, nonatomic) OQJNavCon * hxChatNavCon;

@end
