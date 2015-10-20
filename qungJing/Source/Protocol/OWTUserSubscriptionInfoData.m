//
//  OWTCategorySubscriptionInfo.m
//  Weitu
//
//  Created by Su on 5/11/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUserSubscriptionInfoData.h"

@implementation OWTUserSubscriptionInfoData

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _subscribedCategoryIDs = [NSMutableArray array];
    }
    return self;
}

@end
