//
//  OWTComment.h
//  Weitu
//
//  Created by Su on 4/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWTCommentData : NSObject

@property (nonatomic, copy) NSString* commentID;
@property (nonatomic, copy) NSString* userID;
@property (nonatomic, copy) NSString* content;
@property (nonatomic, copy) NSNumber* timestamp;

@end
