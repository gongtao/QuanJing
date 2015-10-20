//
//  OWTUserFlowViewCon.h
//  Weitu
//
//  Created by Su on 6/16/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHRefreshControl.h"

@interface OWTUserFlowViewCon : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, XHRefreshControlDelegate>

@property (nonatomic, assign) BOOL isShowingFollowerUsers;

@property (nonatomic, strong) int (^numberOfUsersFunc)();
@property (nonatomic, strong) OWTUser* (^userAtIndexFunc)(NSUInteger index);
@property (nonatomic, strong) void (^onUserSelectedFunc)(OWTUser* user);
@property (nonatomic, strong) void (^refreshDataFunc)(void (^refreshDoneFunc)());
@property (nonatomic, strong) void (^loadMoreDataFunc)(void (^loadDoneFunc)());
@property (nonatomic, strong) NSNumber* totalUserNum;

- (void)manualRefresh;
- (void)loadMoreData;
- (void)reloadData;

@end
