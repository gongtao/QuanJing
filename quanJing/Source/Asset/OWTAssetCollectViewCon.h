//
//  OWTAssetCollectViewCon.h
//  Weitu
//
//  Created by Su on 7/1/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWTAssetCollectViewCon : UITableViewController

- (id)initWithAsset:(OWTAsset*)asset;

@property (nonatomic, strong) void (^doneAction)(EWTDoneType doneType);

@end
