//
//  SWRefreshControl.m
//  Weitu
//
//  Created by Su on 4/10/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "ORefreshControl.h"

@implementation ORefreshControl

- (void)beginRefreshing
{
    // Only do this specific "hack" if super view is a collection view
    if ([[self superview] isKindOfClass:[UICollectionView class]])
    {
        UICollectionView *superCollectionView = (UICollectionView *)[self superview];

        // If the user did change the content offset we do not want to animate a new one
        CGPoint contentOffset = [superCollectionView contentOffset];
        if (CGPointEqualToPoint(contentOffset, CGPointMake(-_knownContentInset.left, -_knownContentInset.top)))
        {
            // Set the new content offset based on UIRefreshControl height
            [superCollectionView setContentOffset:CGPointMake(-_knownContentInset.left, -_knownContentInset.top -CGRectGetHeight([self frame])) animated:YES];

            [super beginRefreshing];
        }
        else
        {
            [super beginRefreshing];
        }
    }
    else
    {
        [super beginRefreshing];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    DDLogDebug(@"Warning: setting background color on a UIRefreshControl is causing unexpected behavior");
}

@end
