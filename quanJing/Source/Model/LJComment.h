//
//  LJComment.h
//  Weitu
//
//  Created by qj-app on 15/5/22.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LJComment : NSObject

@property(nonatomic,copy)NSString *activityId;
@property(nonatomic,copy)NSString *content;
@property(nonatomic,copy)NSString *posttime;
@property(nonatomic,copy)NSString *userid;
@property(nonatomic,copy)NSString *replyuserid;
@end
