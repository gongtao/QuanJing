//
//  LJHomeVIewCellTableViewCell.m
//  Weitu
//
//  Created by qj-app on 15/8/14.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJHomeVIewCellTableViewCell.h"
#import <UIImageView+WebCache.h>

@implementation LJHomeVIewCellTableViewCell
{
	UIImageView * _imageView;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
	if (self)
		[self setUp];
	return self;
}

- (void)setUp
{
	float x = 356;
	float y = 640;
	
	_imageView = [LJUIController createImageViewWithFrame:CGRectMake(0, 0, SCREENWIT, x / y * SCREENWIT) imageName:nil];
	[self.contentView addSubview:_imageView];
}

- (void)setImageWithUrl:(NSString *)url
{
	_imageView.alpha = 0.0;
	__weak UIImageView * weakImageView = _imageView;
	[_imageView setImageWithURL:[NSURL URLWithString:url]
	placeholderImage:nil
	completed:^(UIImage * image, NSError * error, SDImageCacheType cacheType) {
		if (cacheType == SDImageCacheTypeNone) {
			[UIView animateWithDuration:0.3
			animations:^{
				weakImageView.alpha = 1.0;
			}];
			return;
		}
		weakImageView.alpha = 1.0;
	}];
}

@end
