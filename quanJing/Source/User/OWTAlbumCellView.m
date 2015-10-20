//
//  OWTAlbumCellView.m
//  Weitu
//
//  Created by Su on 4/14/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTAlbumCellView.h"

@interface OWTAlbumCellView()
{
    UIImageView* _imageView;
}

@end

@implementation OWTAlbumCellView

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
    _imageView = [[UIImageView alloc] initWithFrame:self.contentView.frame];
    [self.contentView addSubview:_imageView];
}

- (void)setImage:(UIImage *)image
{
    _imageView.image = image;
}

- (UIImage*)image
{
    return _imageView.image;
}

@end
