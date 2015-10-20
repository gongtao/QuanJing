//
//  LJSearchCell.m
//  Weitu
//
//  Created by qj-app on 15/9/8.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJSearchCell.h"

@implementation LJSearchCell

- (void)awakeFromNib {
    
    UILabel *line=[LJUIController createLabelWithFrame:CGRectMake(0, 29.8, SCREENWIT, 0.2) Font:12 Text:nil];
    line.backgroundColor=[UIColor blackColor];
    [self.contentView addSubview:line];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
