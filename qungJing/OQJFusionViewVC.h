//
//  OQJFusionViewVC.h
//  Weitu
//
//  Created by denghs on 15/9/18.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWaterFlowLayoutDataSource.h"
#import "XHRefreshControl.h"
#import "UIViewController+BackButtonHandler.h"
#import "FusionScrollView.h"
@interface OQJFusionViewVC : UIViewController<OWaterFlowLayoutDataSource, UICollectionViewDelegate, XHRefreshControlDelegate,FusionDelegate,UITextFieldDelegate,UISearchBarDelegate>
@property (nonatomic, assign)NSInteger VcTag;
@property (nonatomic, strong)NSString *contentType;

@end

