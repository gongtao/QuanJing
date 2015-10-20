//
//  UIControl+Blocks.m
//  Lego
//
//  Created by Bing SU on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIControl+Blocks.h"
#import <objc/runtime.h>

@implementation UIControl (Blocks)

#pragma -
#pragma Blocks

static char overviewKey;

@dynamic touchUpInsideAction;

- (void)setPressedAction:(void (^)())pressedAction
{
    if (pressedAction != nil)
    {
        if (self.touchUpInsideAction == nil)
        {
            [self addTarget:self action:@selector(doTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        }
        self.touchUpInsideAction = [pressedAction copy];
    }
    else
    {
        if (self.touchUpInsideAction != nil)
        {
            [self removeTarget:self action:@selector(doTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        }
        self.touchUpInsideAction = nil;
    }

    objc_setAssociatedObject (self, &overviewKey, pressedAction, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)())pressedAction
{
    return objc_getAssociatedObject(self, &overviewKey);
}

- (void)doTouchUpInside:(id)sender
{
    if (self.touchUpInsideAction != nil)
    {
        self.touchUpInsideAction();
    }
}

@end
