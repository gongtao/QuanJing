//
//  LJCollectionReusableView.h
//  Weitu
//
//  Created by qj-app on 15/5/27.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJCollectionReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *constellationLabel;
@property (weak, nonatomic) IBOutlet UILabel *emotionStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *signLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthplaceLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *hobbyLabel;

@property (weak, nonatomic) IBOutlet UILabel *jobLabel;
@property(nonatomic,retain)UILabel *signLabel1;
@property(nonatomic,retain)UILabel *hobbyLabel1;
@end
