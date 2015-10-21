//
//  QJCommentObject.m
//  QuanJingSDK
//
//  Created by QJ on 15/10/20.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import "QJCommentObject.h"

#import "QJCoreMacros.h"

@implementation QJCommentObject

- (instancetype)initWithJson:(nullable NSDictionary *)json
{
    self = [super init];
    
    if (self)
        [self setPropertiesFromJson:json];
    return self;
}

- (void)setPropertiesFromJson:(NSDictionary *)json
{
    if (QJ_IS_DICT_NIL(json))
        return;
    
    // user
    self.user = [[QJUser alloc] initWithJson:json];
    
    // comment
    NSString * comment = json[@"comment"];
    
    if (!QJ_IS_STR_NIL(comment))
        self.comment = comment;
    
    // time
    NSNumber * time = json[@"time"];
    
    if (!QJ_IS_NUM_NIL(time))
        self.time = [NSDate dateWithTimeIntervalSince1970:time.longLongValue];
}

@end
