//
//  LJCollectionCell.m
//  Weitu
//
//  Created by qj-app on 15/6/24.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJCollectionCell.h"
#import "LJUIController.h"
@implementation LJCollectionCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView=[LJUIController createImageViewWithFrame:self.contentView.bounds imageName:nil];
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
        [_imageView addGestureRecognizer:tap];
        [self.contentView addSubview:_imageView];
    }
    return self;
}
-(void)tap
{
    _touchImagecb();
}
@end
