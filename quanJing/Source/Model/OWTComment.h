//
//  OWTComment.h
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTCommentData.h"

@interface OWTComment : NSObject

@property (nonatomic, strong) NSString* commentID;
@property (nonatomic, strong) NSString* userID;
@property (nonatomic, strong) NSString* content;
@property (nonatomic, assign) long long timestamp;

- (void)mergeWithData:(OWTCommentData*)commentData;

@end
