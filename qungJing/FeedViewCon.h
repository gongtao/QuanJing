//
//  OWTFeedViewCon.h
//  Weitu
//
//  Created by Su on 3/10/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWTFeed.h"
#import "OWaterFlowLayoutDataSource.h"
#import "XHRefreshControl.h"
#import "UIViewController+BackButtonHandler.h"
@interface FeedViewCon : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, OWaterFlowLayoutDataSource, XHRefreshControlDelegate>

@property (nonatomic, readonly) OWTFeed* feed;

- (void)presentFeed:(OWTFeed*)feed animated:(BOOL)animated refresh:(BOOL)refresh;
- (void)manualRefresh;
- (void)manualRefreshIfNeeded;

@end
