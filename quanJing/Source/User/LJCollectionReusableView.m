//
//  LJCollectionReusableView.m
//  Weitu
//
//  Created by qj-app on 15/5/27.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJCollectionReusableView.h"
#import <AFNetworking.h>
#import "LJUIController.h"
@implementation LJCollectionReusableView

- (void)awakeFromNib {
    // Initialization code
    //_signLabel.adjustsFontSizeToFitWidth=YES;
//    _signLabel.numberOfLines=0;
//    _signLabel.lineBreakMode=NSLineBreakByWordWrapping;
    _signLabel1=[LJUIController createLabelWithFrame:CGRectMake(101, 167, 197, 27) Font:12 Text:nil];
    [self addSubview:_signLabel1];
    _hobbyLabel1=[LJUIController createLabelWithFrame:CGRectMake(102, 390, 197, 27) Font:12 Text:nil];
    [self addSubview:_hobbyLabel1];
    }
@end
