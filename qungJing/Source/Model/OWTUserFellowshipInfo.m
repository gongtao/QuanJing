//
//  OWTUserFellowshipInfo.m
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUserFellowshipInfo.h"

@implementation OWTUserFellowshipInfo

- (void)mergeWithData:(OWTUserFellowshipInfoData*)fellowshipInfoData
{
    if (fellowshipInfoData.followingNum != nil)
    {
        _followingNum = fellowshipInfoData.followingNum.integerValue;
    }

    if (fellowshipInfoData.followerNum != nil)
    {
        _followerNum = fellowshipInfoData.followerNum.integerValue;
    }

    if (fellowshipInfoData.followingUserIDs != nil)
    {
        _followingUserIDs = [NSMutableSet setWithArray:fellowshipInfoData.followingUserIDs];
    }
}

@end
