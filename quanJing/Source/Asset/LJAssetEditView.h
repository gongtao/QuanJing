//
//  LJAssetEditView.h
//  Weitu
//
//  Created by qj-app on 15/5/27.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWTAsset.h"
@interface LJAssetEditView : UIViewController
- (id)initWithAsset:(OWTAsset*)asset deletionAllowed:(BOOL)deletionAllowed;
@property (nonatomic, strong) OWTAsset* asset;
@property (nonatomic, assign) BOOL deletionAllowed;
@property (nonatomic, strong) void (^doneAction)(EWTDoneType doneType);
@end
