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
#import "UIViewController+BackButtonHandler.h"

@interface OQJExploreViewGeneral : UIViewController<OWaterFlowLayoutDataSource, UICollectionViewDelegate, XHRefreshControlDelegate>
@property (nonatomic, assign)NSInteger VcTag;
@end
