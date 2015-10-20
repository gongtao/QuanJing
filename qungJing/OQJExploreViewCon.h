//
//  OQJCategoryViewCon.h
//  Weitu
//
//  Created by Su on 8/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XHRefreshControl.h"
#import "OWTCategoryTableViewCell.h"

#import "JCTopic.h"
@interface OQJExploreViewCon : UIViewController<UIScrollViewDelegate,XHRefreshControlDelegate,JCTopicDelegate,UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
- (instancetype)initWithPage:(NSInteger)page;
@property (nonatomic, assign)NSInteger titleCount;
@property (nonatomic, copy)NSArray *sortArr;
@property(nonatomic,assign)NSInteger pCount;
@end
