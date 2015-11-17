//
//  OWTUserViewCon.h
//  Weitu
//
//  Created by Su on 4/12/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHRefreshControl.h"
#import "QuanJingSDK.h"
#import "LJFeedWithUserProfileViewCon.h"
@interface OWTUserViewCon : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, XHRefreshControlDelegate>

@property (nonatomic, strong) OWTUser * user;
@property(nonatomic, strong) QJUser * quser;
@property (nonatomic, strong) int (^numberOfAssetsFunc)();
@property (nonatomic, strong) OWTAsset *(^assetAtIndexFunc)(NSInteger index);
@property (nonatomic, strong) void (^onAssetSelectedFunc)(OWTAsset * asset);
@property (nonatomic, strong) void (^refreshDataFunc)(void (^ refreshDoneFunc)());
@property (nonatomic, strong) void (^loadMoreDataFunc)(void (^ loadDoneFunc)());
@property (nonatomic, strong) NSNumber * totalAssetNum;
@property (nonatomic, assign) BOOL rightTriggle;
@property (nonatomic, assign) BOOL ifFirstEnter;
@property(nonatomic,strong)LJFeedWithUserProfileViewCon *viewController;
@property(nonatomic,assign)NSInteger pageNumber;
- (void)adealloc;
@end
