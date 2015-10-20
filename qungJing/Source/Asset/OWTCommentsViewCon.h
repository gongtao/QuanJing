//
//  OWTCommentsViewCon.h
//  Weitu
//
//  Created by Su on 4/25/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWTAsset.h"

@interface OWTCommentsViewCon : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) OWTAsset* asset;

@end
