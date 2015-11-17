//
//  OWTAssetEditViewCon.h
//  Weitu
//
//  Created by Su on 6/30/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuanJingSDK.h"
@interface OWTAssetEditViewCon : UITableViewController

@property (nonatomic, strong) void (^doneAction)(EWTDoneType doneType);

- (id)initWithAsset:(QJImageObject*)asset deletionAllowed:(BOOL)deletionAllowed;

@end
