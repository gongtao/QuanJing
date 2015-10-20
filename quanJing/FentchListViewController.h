//
//  FentchListViewController.h
//  Weitu
//
//  Created by denghs on 15/5/27.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMChatManagerUtilDelegate.h"
#import "BaseViewController.h"

@interface FentchListViewController : BaseViewController

- (void)refreshDataSource;

- (void)isConnect:(BOOL)isConnect;
- (void)networkChanged:(EMConnectionState)connectionState;

@end
