//
//  OQJCategoryCell.m
//  Weitu
//
//  Created by Su on 8/24/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OQJCategoryCell.h"
#import "OWTImageView.h"
#import "OWTCategory.h"
#import "UIView+EasyAutoLayout.h"
#import <NSLayoutConstraint+ExpressionFormat/NSLayoutConstraint+ExpressionFormat.h>

@interface OQJCategoryCell()
{
    UILabel* _nameLabel;
    OWTImageView* _imageView;
}

@end

@implementation OQJCategoryCell

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
    _imageView = [[OWTImageView alloc] initWithFrame:CGRectZero];
    [_imageView easyFillSuperview];
    [self addSubview:_imageView];

    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _nameLabel.font = [UIFont boldSystemFontOfSize:20];
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.shadowColor = [UIColor blackColor];
    _nameLabel.shadowOffset = CGSizeMake(0, 0.5);

    [self addSubview:_nameLabel];

    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary* parameters = @{ @"view" : _nameLabel };
    [self addConstraint:[NSLayoutConstraint constraintWithExpressionFormat:@"view.left = superview.left + 10" parameters:parameters]];
    [self addConstraint:[NSLayoutConstraint constraintWithExpressionFormat:@"view.bottom = superview.bottom - 10" parameters:parameters]];
}

- (void)setCategory:(OWTCategory *)category
{
    _category = category;
    if (_category != nil)
    {
        [_imageView setImageWithInfo:_category.coverImageInfo];
        _nameLabel.text = _category.categoryName;
    }
    else
    {
        [_imageView clearImageAnimated:NO];
        _nameLabel.text = nil;
    }
}

- (void)prepareForReuse
{
    self.category = nil;
}

@end
