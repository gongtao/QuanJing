//
//  UIViewController+WTExt.h
//  Weitu
//
//  Created by Su on 4/25/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (WTExt)

- (void)substituteNavigationBarBackItem;
- (void)substituteNavigationBarBackItem2;

- (UIBarButtonItem*)createCircleBackBarButtonItemWithTarget:(id)target action:(SEL)action;

@end
