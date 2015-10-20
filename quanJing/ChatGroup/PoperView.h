//
//  PoperView.h
//  Weitu
//
//  Created by denghs on 15/6/1.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PoperView : UIImageView
@property (nonatomic, strong) void (^showFriendList)();
@property (nonatomic, strong) void (^addgroudTalk)();
@property (nonatomic, strong) void (^showContact)();
@end
