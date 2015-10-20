//
//  OWaterFlowCell.m
//  Weitu
//
//  Created by Su on 3/8/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTImageCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface OWTImageCell ()

@end

@implementation OWTImageCell

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
    self.clipsToBounds = YES;

    _imageView = [[OWTImageView alloc] initWithFrame:self.contentView.bounds];
    _imageView.maintainAspectRatio = NO;
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_imageView];

    NSDictionary* parameters = @{ @"view" : _imageView };
    [self addConstraint:[NSLayoutConstraint constraintWithExpressionFormat:@"view.left = superview.left" parameters:parameters]];
    [self addConstraint:[NSLayoutConstraint constraintWithExpressionFormat:@"view.right = superview.right" parameters:parameters]];
    [self addConstraint:[NSLayoutConstraint constraintWithExpressionFormat:@"view.top = superview.top" parameters:parameters]];
    [self addConstraint:[NSLayoutConstraint constraintWithExpressionFormat:@"view.bottom = superview.bottom" parameters:parameters]];
}

- (void)setImageWithInfo:(OWTImageInfo*)imageInfo
{
    [self.imageView setImageWithInfo:imageInfo];
}

- (void)setImageWithImage:(UIImage*)image
{
    [self.imageView setImageWithImage:image];
}

- (void)prepareForReuse
{
    [self.imageView clearImageAnimated:NO];
}

- (void)clearImage
{
    [self.imageView clearImageAnimated:YES];
}

@end
