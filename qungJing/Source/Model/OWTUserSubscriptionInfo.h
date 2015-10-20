//
//  OWTUserSubscriptionInfo.h
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUserSubscriptionInfoData.h"

@interface OWTUserSubscriptionInfo : NSObject

@property (nonatomic, copy) NSArray* subscribedCategoryIDs;

- (void)mergeWithData:(OWTUserSubscriptionInfoData*)subscriptionInfoData;

@end
