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
#import "JCTopic.h"


@interface OWTFeedViewCon : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, OWaterFlowLayoutDataSource, XHRefreshControlDelegate,JCTopicDelegate,NSURLConnectionDataDelegate>


@property (nonatomic, readonly) OWTFeed* feed;
@property (nonatomic, strong) UICollectionView* collectionView;
@property (strong, nonatomic)  UIPageControl *page;
@property (strong, nonatomic) NSMutableArray *showArr;

- (void)presentFeed:(OWTFeed*)feed animated:(BOOL)animated refresh:(BOOL)refresh;
- (void)manualRefresh;
- (void)manualRefreshIfNeeded;

@end
