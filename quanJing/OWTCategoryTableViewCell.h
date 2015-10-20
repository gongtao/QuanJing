//
//  OWTCategoryCell.h
//  Weitu
//
//  Created by Su on 5/11/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWTImageView.h"
//
//@class OWTCategoryTableViewCell;
//
//@protocol OWTCategoryTableViewCellDelegate
//
//@required
//- (void)categoryCellSubscribeButtonPressed:(OWTCategoryTableViewCell*)categoryCell;
//
//@end

@interface OWTCategoryTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet OWTImageView *thumbImageV;
@property (weak, nonatomic) IBOutlet UILabel *SubtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *SummaryLabel;

@end
