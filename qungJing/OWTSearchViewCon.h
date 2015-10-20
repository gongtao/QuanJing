//
//  OWTSearchViewCon.h
//  Weitu
//
//  Created by Su on 4/25/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWTSearchViewCon : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource,UISearchBarDelegate>

- (void)setKeyword:(NSString *)keyword withAssets:(NSArray*)assets;
@end
