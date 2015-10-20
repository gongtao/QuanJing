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
#import "UIViewController+BackButtonHandler.h"
#import "JCTopic.h"

@interface OQJExploreViewCon1 : UIViewController<UIScrollViewDelegate,XHRefreshControlDelegate,JCTopicDelegate,UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic, assign)NSInteger titleCount;
@property (nonatomic, copy)NSArray *sortArr;
@property (nonatomic, assign)NSString *titleString;
@property (nonatomic, assign)NSInteger classCount;
@property(nonatomic,strong)UITableView *tableView;
@end
