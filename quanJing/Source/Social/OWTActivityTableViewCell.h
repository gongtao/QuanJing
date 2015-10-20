//
//  OWTActivityTableViewCell.h
//  Weitu
//
//  Created by Su on 6/3/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "OWTMergedActivity.h"

@interface OWTActivityTableViewCell : UITableViewCell<TTTAttributedLabelDelegate>

@property (nonatomic, strong) OWTMergedActivity* mergedActivity;

@property (nonatomic, strong) void (^userClickedAction)(NSString*);
@property (nonatomic, strong) void (^assetClickedAction)(NSString*);

@end
