//
//  OQJCategoryViewCon.h
//  Weitu
//
//  Created by Su on 8/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWaterFlowLayoutDataSource.h"
#import "XHRefreshControl.h"

@interface OQJExploreViewConlvyouinternational2 : UIViewController<OWaterFlowLayoutDataSource, UICollectionViewDelegate, XHRefreshControlDelegate>
@property (nonatomic, strong) UICollectionView* collectionView;
@end
