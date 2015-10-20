//
//  OWTActivitiesViewCon.h
//  Weitu
//
//  Created by Su on 6/3/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHRefreshControl.h"

@interface OWTActivitiesViewCon : UITableViewController<XHRefreshControlDelegate>

- (instancetype)initWithDefaultStyle;
- (void)refreshIfNeeded;
- (void)manualRefresh;
@end
