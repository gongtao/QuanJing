//
//  OWTUserInfoViewCon.h
//  Weitu
//
//  Created by Su on 4/12/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGIPCPreviewController.h"
#import "OWTUserViewCon.h"
#import "OWTRoundImageView.h"

@protocol OWTUserInfoViewCareDelegate <NSObject>

- (void)didCareButtonPressed:(BOOL)isCared;

@end

@interface OWTUserInfoView1 : UICollectionReusableView<AGIPCPreviewControllerDelegate>

@property (nonatomic, strong) OWTUser* user;
@property (nonatomic, assign) NSInteger selfNum;
@property (nonatomic,strong)OWTUserViewCon *owtUserViewVC;
@property (nonatomic, strong) void (^editUserInfoAction)();

@property (nonatomic, strong) void (^showAssetsAction)();
@property (nonatomic, strong) void (^showAvatorAction)();

@property (nonatomic, strong) void (^showLikedAssetsAction)();
@property (nonatomic, strong) void (^showFollowingsAction)();
@property (nonatomic, strong) void (^showFollowersAction)();

@property (nonatomic, strong) NSMutableSet* followingUsers;
@property (nonatomic, strong) OWTRoundImageView* mAvatarView;
@property (nonatomic, assign) BOOL ifCurrenUserEnter;
@property (nonatomic, assign) BOOL isCared;

@property (nonatomic, weak) id<OWTUserInfoViewCareDelegate> careDelegate;

- (void)careButtonPressed;

@end
