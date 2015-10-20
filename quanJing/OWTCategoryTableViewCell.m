//
//  OWTCategoryCell.m
//  Weitu
//
//  Created by Su on 5/11/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTCategoryTableViewCell.h"
#import "OWTImageView.h"
#import "UIView+EasyAutoLayout.h"
#import "OWTFont.h"
#import "UIButton+HitTestExt.h"
#import <KHFlatButton/KHFlatButton.h>
#import <FLKAutoLayout/UIView+FLKAutoLayout.h>

@interface OWTCategoryTableViewCell ()
{
    
}

@end

@implementation OWTCategoryTableViewCell

- (void)awakeFromNib
{
    _thumbImageV.fadeTransitionEnabled = NO;
    _thumbImageV.maintainAspectRatio = NO;
    _thumbImageV.layer.cornerRadius = 2;
    _thumbImageV.clipsToBounds = YES;


}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
//    if (highlighted)
//    {
//        self.contentView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
//    }
//    else
//    {
//        self.contentView.backgroundColor = nil;
//    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
//    if (selected)
//    {
//        self.contentView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
//    }
//    else
//    {
//        self.contentView.backgroundColor = nil;
//    }
}


@end
