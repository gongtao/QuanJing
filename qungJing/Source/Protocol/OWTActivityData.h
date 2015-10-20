//
//  OWTActivity.h
//  Weitu
//
//  Created by Su on 6/3/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWTActivityData : NSObject

@property (nonatomic, copy) NSNumber* timestamp;
@property (nonatomic, copy) NSString* activityType;
@property (nonatomic, copy) NSString* userID;
@property (nonatomic, copy) NSString* subjectUserID;
@property (nonatomic, copy) NSString* subjectAssetID;
@property(nonatomic,copy)NSString *commentid;
@property (nonatomic, copy) NSString* friendsOrFans;
@end
