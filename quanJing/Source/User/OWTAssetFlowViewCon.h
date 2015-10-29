//
//  OWTAssetFlowViewCon.h
//  Weitu
//
//  Created by Su on 6/14/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XHRefreshControl.h"

@interface OWTAssetFlowViewCon : UIViewController<UICollectionViewDelegate,
                                                  UICollectionViewDataSource,
                                                  XHRefreshControlDelegate>

@property (nonatomic, strong) int (^numberOfAssetsFunc)();
@property (nonatomic, strong) OWTAsset* (^assetAtIndexFunc)(NSInteger index);
@property (nonatomic, strong) void (^onAssetSelectedFunc)(OWTAsset* asset);
@property (nonatomic, strong) void (^refreshDataFunc)(void (^refreshDoneFunc)());
@property (nonatomic, strong) void (^loadMoreDataFunc)(void (^loadDoneFunc)());
@property (nonatomic, strong) NSNumber* totalAssetNum;
@property (nonatomic, strong) UICollectionView* collectionView;
- (void)manualRefresh;
- (void)loadMoreData;
- (void)reloadData;

@end
