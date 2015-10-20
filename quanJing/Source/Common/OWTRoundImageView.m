//
//  OWTRoundImageView.m
//  Weitu
//
//  Created by Su on 5/9/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTRoundImageView.h"

@implementation OWTRoundImageView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    [super setup];
    self.layer.masksToBounds = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateCornerRadius];
}

- (void)updateCornerRadius
{
    CGFloat minLength = MIN(self.bounds.size.width, self.bounds.size.height);
    self.layer.cornerRadius = minLength * 0.5;
}

@end
