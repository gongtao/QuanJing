//
//  OWTMainViewCon.h
//  Weitu
//
//  Created by Su on 3/8/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ChatListViewController;
@interface OWTMainViewCon : UITabBarController <UITabBarControllerDelegate>
@property (nonatomic, strong) UIImageView *redPointView;
@property (nonatomic, strong) ChatListViewController * chatListVC;
- (void)jumpToChatList;

@end
