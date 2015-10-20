//
//  UIView+EasyAutoLayout.m
//  Weitu
//
//  Created by Su on 5/11/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "UIView+EasyAutoLayout.h"
#import <NSLayoutConstraint+ExpressionFormat/NSLayoutConstraint+ExpressionFormat.h>

@implementation UIView (EasyAutoLayout)

- (void)easyFillSuperview
{
    if (self.superview != nil)
    {
        self.translatesAutoresizingMaskIntoConstraints = NO;

        NSDictionary* parameters = @{ @"view" : self };
        [self.superview addConstraint:[NSLayoutConstraint constraintWithExpressionFormat:@"view.left = superview.left" parameters:parameters]];
        [self.superview addConstraint:[NSLayoutConstraint constraintWithExpressionFormat:@"view.right = superview.right" parameters:parameters]];
        [self.superview addConstraint:[NSLayoutConstraint constraintWithExpressionFormat:@"view.top = superview.top" parameters:parameters]];
        [self.superview addConstraint:[NSLayoutConstraint constraintWithExpressionFormat:@"view.bottom = superview.bottom" parameters:parameters]];
    }
    else
    {
        NSAssert(false, @"UIView must have a superview when using easyFillSuperview.");
    }
}

- (void)easyCenterInSuperview
{
    if (self.superview != nil)
    {
        self.translatesAutoresizingMaskIntoConstraints = NO;

        NSDictionary* parameters = @{ @"view" : self };
        [self.superview addConstraint:[NSLayoutConstraint constraintWithExpressionFormat:@"view.centerX = superview.centerX" parameters:parameters]];
        [self.superview addConstraint:[NSLayoutConstraint constraintWithExpressionFormat:@"view.centerY = superview.centerY" parameters:parameters]];
    }
    else
    {
        NSAssert(false, @"UIView must have a superview when using easyCenterInSuperview.");
    }
}


@end
