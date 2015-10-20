//
//  OWTSearchResultsViewCon.h
//  Weitu
//
//  Created by Su on 7/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+WTExt.h"

@interface OWTSearchResultsViewCon : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource,UISearchBarDelegate>

- (void)setKeyword:(NSString *)keyword withAssets:(NSArray*)assets;
//
- (void)setKeyword:(NSString *)keyword;
@end
