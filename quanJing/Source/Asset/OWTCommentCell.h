//
//  OWTCommentCell.h
//  Weitu
//
//  Created by Su on 4/25/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWTComment.h"

@interface OWTCommentCell : UITableViewCell

@property (nonatomic, strong) OWTComment* comment;
@property (nonatomic, strong) void ((^showUserAction)());

@end
