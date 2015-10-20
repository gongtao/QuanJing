//
//  captionCell.h
//  Weitu
//
//  Created by qj-app on 15/7/9.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface captionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property(nonatomic,strong)UIButton *number;

@end
