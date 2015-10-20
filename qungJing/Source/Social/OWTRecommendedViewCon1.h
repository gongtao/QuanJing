//
//  OWTRecommendedViewCon.h
//  Weitu
//
//  Created by Su on 8/17/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHRefreshControl.h"

@interface OWTRecommendedViewCon1 : UITableViewController<XHRefreshControlDelegate>
- (void)refreshIfNeeded;
@end
