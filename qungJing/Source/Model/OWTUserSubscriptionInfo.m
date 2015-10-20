//
//  OWTUserSubscriptionInfo.m
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUserSubscriptionInfo.h"

@implementation OWTUserSubscriptionInfo

- (void)mergeWithData:(OWTUserSubscriptionInfoData*)subscriptionInfoData
{
    if (subscriptionInfoData.subscribedCategoryIDs != nil)
    {
        _subscribedCategoryIDs = subscriptionInfoData.subscribedCategoryIDs;
    }
}

@end
