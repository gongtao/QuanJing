//
//  OWTUserFellowshipCell.h
//  Weitu
//
//  Created by Su on 6/16/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuanJingSDK.h"
@interface OWTUserFellowshipCell : UICollectionViewCell

- (void)setUser:(QJUser *)user isFollowerUser:(BOOL)isFollowerUser;

@end
