//
//  FriendListViewController.h
//  Weitu
//
//  Created by denghs on 15/5/28.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface AddFriendListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong)NSArray *existMenberArray;
@property (nonatomic, strong) void (^creatGroupPopBack)(EMGroup *group);
@property (nonatomic, strong)void (^addFriendToGrop)(NSArray *newMenber);

@property(nonatomic, strong)NSString *gropName;
@property (nonatomic, strong)id contactVC;
@end
