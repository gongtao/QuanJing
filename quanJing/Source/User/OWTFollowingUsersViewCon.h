//
//  OWTFollowingUsersViewCon.h
//  Weitu
//
//  Created by Su on 6/16/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuanJingSDK.h"
@interface OWTFollowingUsersViewCon : UIViewController

@property (nonatomic, strong) QJUser * user;

- (instancetype)initWithUser:(QJUser *)user;

@end
