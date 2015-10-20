//
//  OWTActivity.h
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTActivityData.h"

typedef enum
{
    nWTActivityTypeUNKNOWN = -1,
    nWTActivityTypeUPLOAD = 0,
    nWTActivityTypeLIKE = 1,
    nWTActivityTypeCOMMENT = 2,
    nWTActivityTypeFOLLOW = 3,
} EWTActivityType;

@interface OWTActivity : NSObject

@property (nonatomic, assign, readonly) long long timestamp;
@property (nonatomic, assign, readonly) EWTActivityType activityType;
@property (nonatomic, strong, readonly) NSString* userID;
@property (nonatomic, strong, readonly) NSString* subjectUserID;
@property (nonatomic, strong, readonly) NSString* subjectAssetID;

@property (nonatomic, strong, readonly) NSString* friendsOrFans;
- (void)mergeWithData:(OWTActivityData*)activityData;

@end
