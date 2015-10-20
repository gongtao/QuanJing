//
//  LJExploreViewCellTableViewCell.m
//  Weitu
//
//  Created by qj-app on 15/9/16.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJExploreViewCellTableViewCell.h"
#import "OWTexploreModel.h"
#import "UIColor+HexString.h"
@implementation LJExploreViewCellTableViewCell
{
    UIImageView *_imageView;
    UILabel *_mainTitle;
    UILabel *_subTitle;
    UIImageView *_grayView;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self customUI];
    }
    
    return self;
}
-(void)customUI
{
    _imageView=[LJUIController createImageViewWithFrame:CGRectMake(0, 10, SCREENWIT, 160) imageName:nil];
    [self.contentView addSubview:_imageView];
    _mainTitle=[LJUIController createLabelWithFrame:CGRectMake(10, 180, SCREENWIT, 20) Font:14 Text:nil];
    _mainTitle.textColor=[UIColor colorWithHexString:@"#525252"];
    [self.contentView addSubview:_mainTitle];
    _subTitle=[LJUIController createLabelWithFrame:CGRectZero Font:12 Text:nil];
    _subTitle.textColor=[UIColor colorWithHexString:@"#a2a2a2"];
    [self.contentView addSubview:_subTitle];
    _grayView=[LJUIController createImageViewWithFrame:CGRectZero imageName:nil];
    _grayView.backgroundColor=[UIColor colorWithHexString:@"#f6f6f6"];
    [self.contentView addSubview:_grayView];
}
-(void)customTheView:(OWTexploreModel*)category
{
    NSMutableString *urlStr=[[NSMutableString alloc]initWithString:category.CoverUrl];
    NSRange range=[urlStr rangeOfString:@"cover"];
    [urlStr replaceCharactersInRange:range withString:@"bigcover"];
    [_imageView setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@""]];
    _mainTitle.text= category.Caption;
    CGSize size=[category.Summary sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(SCREENWIT-20, 200)];
    _subTitle.frame=CGRectMake(10, 205, SCREENWIT-10, size.height);
    _subTitle.text=category.Summary;
    _grayView.frame=CGRectMake(0, 210+size.height, SCREENWIT, 10);
}
@end
