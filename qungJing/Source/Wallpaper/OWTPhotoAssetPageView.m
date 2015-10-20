//
//  OWTPhotoAssetPageView.m
//  WhiteCloud
//
//  Created by Su on 3/6/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTPhotoAssetPageView.h"
#import "OWTImageView.h"

@interface OWTPhotoAssetPageView ()
{
    OWTImageView* _photoView;
}

@end

@implementation OWTPhotoAssetPageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _photoView = [[OWTImageView alloc] initWithFrame:self.bounds];
    _photoView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_photoView];

    _photoView.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary* parameters = @{ @"view" : _photoView };
    [self addConstraint:[NSLayoutConstraint constraintWithExpressionFormat:@"view.left = superview.left" parameters:parameters]];
    [self addConstraint:[NSLayoutConstraint constraintWithExpressionFormat:@"view.right = superview.right" parameters:parameters]];
    [self addConstraint:[NSLayoutConstraint constraintWithExpressionFormat:@"view.centerX = superview.centerX" parameters:parameters]];
    [self addConstraint:[NSLayoutConstraint constraintWithExpressionFormat:@"view.centerY = superview.centerY" parameters:parameters]];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [_photoView clearImageAnimated:NO];
}

- (void)assetDidChange
{
    if (self.asset != nil)
    {
        [_photoView setImageWithInfo:self.asset.imageInfo];
    }
    else
    {
        [_photoView clearImageAnimated:YES];
    }
}

@end
