//
//  LJExploreViewController1.h
//  Weitu
//
//  Created by qj-app on 15/9/16.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHRefreshControl.h"
#import "OWTCategoryTableViewCell.h"
#import "JCTopic.h"
@interface LJExploreViewController1 : UIViewController <UIScrollViewDelegate, XHRefreshControlDelegate, JCTopicDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic, assign) NSInteger titleCount;
@property (nonatomic, copy) NSArray * sortArr;

@end
