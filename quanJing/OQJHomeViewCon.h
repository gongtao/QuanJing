//
//  OQJHomeViewCon.h
//  Weitu
//
//  Created by Su on 8/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XHRefreshControl.h"
@interface OQJHomeViewCon : UIViewController<UISearchBarDelegate, UIScrollViewDelegate,UITextFieldDelegate,XHRefreshControlDelegate>
{
    NSMutableArray *data;
    NSMutableArray *companyData;
}
@property (nonatomic, strong) void (^refreshDataFunc)(void (^refreshDoneFunc)());
@property (nonatomic, strong) void (^loadMoreDataFunc)(void (^loadDoneFunc)());

- (void)manualRefresh;
- (void)loadMoreData;
- (void)reloadData;

@end
