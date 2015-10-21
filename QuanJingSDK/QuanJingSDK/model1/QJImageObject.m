//
//  QJImageObject.m
//  QuanJingSDK
//
//  Created by QJ on 15/10/19.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import "QJImageObject.h"

#import "QJCoreMacros.h"

@implementation QJImageObject

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
    
    // imageId
    NSNumber * imageId = json[@"id"];
    if (!QJ_IS_NUM_NIL(imageId))
        self.imageId = imageId;
    
    // userId
    NSNumber * userId = json[@"userId"];
    if (!QJ_IS_NUM_NIL(userId))
        self.userId = userId;
    
    // tag
    NSString * tag = json[@"tag"];
    if (!QJ_IS_STR_NIL(tag))
        self.tag = tag;
    
    // url
    NSString * url = json[@"url"];
    if (!QJ_IS_STR_NIL(url))
        self.url = url;
    
    // bgcolor
    NSString * bgcolor = json[@"bgcolor"];
    if (!QJ_IS_STR_NIL(bgcolor))
        self.bgcolor = bgcolor;
    
    // width
    NSNumber * width = json[@"width"];
    if (!QJ_IS_NUM_NIL(width))
        self.width = width;
    
    // height
    NSNumber * height = json[@"height"];
    if (!QJ_IS_NUM_NIL(height))
        self.height = height;
}

@end
