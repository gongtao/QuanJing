//
//  exploreViewController.h
//  Weitu
//
//  Created by sunhu on 14/12/19.
//  Copyright (c) 2014年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface exploreViewController : UIViewController<UIScrollViewDelegate>
@property (nonatomic, assign)NSInteger titleCount;
@property (nonatomic, copy)NSArray *sortArr;
@property (nonatomic, copy)NSString *titleString;

@property (nonatomic, assign)NSArray *titleArray;
@end
