//
//  LJExploreViewCellTableViewCell.h
//  Weitu
//
//  Created by qj-app on 15/9/16.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWTexploreModel.h"
@interface LJExploreViewCellTableViewCell : UITableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
-(void)customTheView:(OWTexploreModel*)model;
@end
