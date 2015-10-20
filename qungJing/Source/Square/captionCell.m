//
//  captionCell.m
//  Weitu
//
//  Created by qj-app on 15/7/9.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "captionCell.h"

@implementation captionCell

- (void)awakeFromNib {
    // Initialization code
    _number=[LJUIController createButtonWithFrame:CGRectZero imageName:nil title:nil target:self action:nil];
    _number.hidden=YES;
    [self addSubview:_number];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end
