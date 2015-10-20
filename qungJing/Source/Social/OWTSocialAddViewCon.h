//
//  OWTSocialAddViewCon.h
//  Weitu
//
//  Created by Su on 8/18/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWTSocialAddViewCon : UIViewController

@property (nonatomic, strong) void (^captureAction)();
@property (nonatomic, strong) void (^uploadAction)();
@property (nonatomic, strong) void (^inviteFriendsAction)();

@end
