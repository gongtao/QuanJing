//
//  OWTUserInfoViewCon.h
//  Weitu
//
//  Created by Su on 4/12/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>



#import "singleton.h"
@interface OWTUserInfoView : UICollectionReusableView

@property (nonatomic, strong) OWTUser* user;
@property (nonatomic, strong) void (^editUserInfoAction)();

@property (nonatomic, strong) void (^showAssetsAction)();
@property (nonatomic, strong) void (^showLikedAssetsAction)();
@property (nonatomic, strong) void (^showFollowingsAction)();
@property (nonatomic, strong) void (^showFollowersAction)();
@property (nonatomic, assign) NSInteger selfNum;
@end
