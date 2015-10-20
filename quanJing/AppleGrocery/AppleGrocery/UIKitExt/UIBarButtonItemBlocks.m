//
//  UIBarButtonItemBlocks.m
//  Lego
//
//  Created by Bing SU on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIBarButtonItemBlocks.h"

@implementation UIBarButtonItemBlocks

@synthesize blockAction = _blockAction;

- (id)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style blockAction:(BlockAction)blockAction
{
    self = [super initWithImage:image style:style target:self action:@selector(superAction)];
    if (self != nil)
    {
        _blockAction = blockAction;
    }
    return self;
}

- (id)initWithImage:(UIImage *)image landscapeImagePhone:(UIImage *)landscapeImagePhone style:(UIBarButtonItemStyle)style blockAction:(BlockAction)blockAction
{
    self = [super initWithImage:image landscapeImagePhone:landscapeImagePhone style:style target:self action:@selector(superAction)];
    if (self != nil)
    {
        _blockAction = blockAction;
    }
    return self;
}

- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style blockAction:(BlockAction)blockAction
{
    self = [super initWithTitle:title style:style target:self action:@selector(superAction)];
    if (self != nil)
    {
        _blockAction = blockAction;
    }
    return self;
}

- (id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem blockAction:(BlockAction)blockAction
{
    self = [super initWithBarButtonSystemItem:systemItem target:self action:@selector(superAction)];
    if (self != nil)
    {
        _blockAction = blockAction;
    }
    return self;
}

- (id)initWithCustomView:(UIView *)customView
{
    self = [super initWithCustomView:customView];
    if (self != nil)
    {
        super.target = self;
        super.action = @selector(superAction);
    }
    return self;
}

- (void)superAction
{
    if (_blockAction != nil)
    {
        _blockAction();
    }
}

@end
