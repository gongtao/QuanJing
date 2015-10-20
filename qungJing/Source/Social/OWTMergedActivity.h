//
//  OWTMergedActivity.h
//  Weitu
//
//  Created by Su on 6/11/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWTActivity.h"

@interface OWTMergedActivity : NSObject

@property (nonatomic, strong, readonly) NSDate* timestamp;
@property (nonatomic, assign, readonly) EWTActivityType activityType;
@property (nonatomic, strong, readonly) NSString* userID;
@property (nonatomic, strong, readonly) NSOrderedSet* subjectUserIDs;
@property (nonatomic, strong, readonly) NSOrderedSet* subjectAssetIDs;


@property (nonatomic, strong, readonly) NSString* friendsOrFans;
- (instancetype)initWithActivities:(NSArray*)activities;

@end
