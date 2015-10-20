//
//  OWTTabBarHider.h
//  Weitu
//
//  Created by Su on 5/8/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWTTabBarHider : NSObject

- (void)notifyScrollViewDidScroll:(UIScrollView*)scrollView;
- (void)notifyScrollViewWillBeginDraggin:(UIScrollView*)scrollView;

- (void)showTabBar;
-(void)hideTabBar;
@end
