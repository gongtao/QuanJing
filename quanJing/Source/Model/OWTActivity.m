//
//  OWTActivity.m
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTActivity.h"

@implementation OWTActivity

- (void)mergeWithData:(OWTActivityData*)activityData
{
    if (activityData == nil)
    {
        return;
    }

    if (activityData.timestamp != nil)
    {
        _timestamp = activityData.timestamp.longLongValue;
    }

    if (activityData.activityType != nil)
    {
        NSString* activityTypeStr = activityData.activityType;

        if ([activityTypeStr isEqualToString:@"upload"])
        {
            _activityType = nWTActivityTypeUPLOAD;
        }
        else if ([activityTypeStr isEqualToString:@"like"])
        {
            _activityType = nWTActivityTypeLIKE;
        }
        else if ([activityTypeStr isEqualToString:@"comment"])
        {
            _activityType = nWTActivityTypeCOMMENT;
        }
        else if ([activityTypeStr isEqualToString:@"follow"])
        {
            _activityType = nWTActivityTypeFOLLOW;
        }
    }
    
    if (activityData.userID != nil)
    {
        _userID = activityData.userID;
        NSLog(@"515151515151%@",activityData.userID);
       
    }
    
    NSLog(@"525252525252%@",activityData.friendsOrFans);
    if (activityData.friendsOrFans != nil)
    {
        _friendsOrFans = activityData.friendsOrFans;
          NSLog(@"525252525252%@",activityData.friendsOrFans);
    }

    
    if (activityData.subjectUserID != nil)
    {
        _subjectUserID = activityData.subjectUserID;
    }
    
    if (activityData.subjectAssetID != nil)
    {
        _subjectAssetID = activityData.subjectAssetID;
    }
}

@end
