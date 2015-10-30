//
//  OWTUserLikedAssetsViewCon.h
//  Weitu
//
//  Created by Su on 6/14/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QJUser.h"

@interface OWTUserLikedAssetsViewCon : UIViewController

@property (nonatomic, strong) QJUser* user1;

- (instancetype)initWithUser:(QJUser *)user;
@end
