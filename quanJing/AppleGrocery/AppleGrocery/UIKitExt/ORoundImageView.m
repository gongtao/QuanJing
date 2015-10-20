//
//  ORoundImageView.m
//  AppleGrocery
//
//  Created by Su on 4/14/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "ORoundImageView.h"

@implementation ORoundImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.layer.masksToBounds = YES;
    }
    return self;
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
