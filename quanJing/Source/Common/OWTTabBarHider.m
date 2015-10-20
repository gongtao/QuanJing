//
//  OWTTabBarHider.m
//  Weitu
//
//  Created by Su on 5/8/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTTabBarHider.h"

@interface OWTTabBarHider ()

@property (nonatomic, assign) CGFloat startContentOffset;
@property (nonatomic, assign) CGFloat lastContentOffset;

@end

@implementation OWTTabBarHider

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _startContentOffset = 0;
        _lastContentOffset = 0;
    }
    return self;
}

- (void)notifyScrollViewDidScroll:(UIScrollView*)scrollView
{
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat differenceFromStart = _startContentOffset - currentOffset;
    CGFloat differenceFromLast = _lastContentOffset - currentOffset;

    _lastContentOffset = currentOffset;

    if ((differenceFromStart) < 0)
    {
        BOOL isFull = scrollView.contentSize.height > scrollView.bounds.size.height * 0.75;
        if (scrollView.isTracking && (abs(differenceFromLast) > 1.0) && isFull)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kWTScrollUpNotification object:nil];
        }
    }
    else
    {
        if (scrollView.isTracking && (abs(differenceFromLast) > 1.0))
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kWTScrollDownNotification object:nil];
        }
    }
}

- (void)notifyScrollViewWillBeginDraggin:(UIScrollView*)scrollView
{
    _lastContentOffset = scrollView.contentOffset.y;
    _startContentOffset = _lastContentOffset;
}

- (void)showTabBar
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kWTShowMainTabBarNotification object:nil];
}
-(void)hideTabBar
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kWTHideMainTabBarNotification object:nil];
}
@end
