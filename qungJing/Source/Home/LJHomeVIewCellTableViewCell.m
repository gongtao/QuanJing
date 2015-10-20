//
//  LJHomeVIewCellTableViewCell.m
//  Weitu
//
//  Created by qj-app on 15/8/14.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJHomeVIewCellTableViewCell.h"

@implementation LJHomeVIewCellTableViewCell
{
    UIImageView *_imageView;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUp];
    }
    return self;
}
-(void)setUp
{
    float x=356;
    float y=640;
    _imageView=[LJUIController createImageViewWithFrame:CGRectMake(0, 0, SCREENWIT, x/y*SCREENWIT) imageName:nil];
    [self.contentView addSubview:_imageView];
}
-(void)setImageWithUrl:(NSString *)url
{

    [_imageView setImageWithURL:[NSURL URLWithString:url]];
}
@end
