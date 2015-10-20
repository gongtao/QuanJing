//
//  OWTActivityMerger.m
//  Weitu
//
//  Created by Su on 6/11/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTActivityMerger.h"

@implementation OWTActivityMerger

- (NSArray*)mergeActivities:(NSArray*)activities
{
    NSMutableArray* mergedActivities = [NSMutableArray array];

    if (activities == nil)
    {
        return mergedActivities;
    }

    NSMutableArray* activitiesCopy = [NSMutableArray arrayWithArray:activities];
    NSMutableArray* pendingMergeActivities = [NSMutableArray array];

    while (activitiesCopy.count > 0)
    {
        OWTActivity* activity = [activitiesCopy lastObject];
        BOOL shouldMerge = [self shouldMergeActivity:activity withActivitys:pendingMergeActivities];
        if (shouldMerge)
        {
            [pendingMergeActivities addObject:activity];
            [activitiesCopy removeLastObject];
            continue;
        }
        else
        {
            OWTMergedActivity* mergedActivity = [[OWTMergedActivity alloc] initWithActivities:pendingMergeActivities];
            [mergedActivities addObject:mergedActivity];
            [pendingMergeActivities removeAllObjects];
            continue;
        }
    }

    if (pendingMergeActivities.count > 0)
    {
        OWTMergedActivity* mergedActivity = [[OWTMergedActivity alloc] initWithActivities:pendingMergeActivities];
        [mergedActivities addObject:mergedActivity];
        [pendingMergeActivities removeAllObjects];
    }

    return mergedActivities;
}

- (BOOL)shouldMergeActivity:(OWTActivity*)activity withActivitys:(NSArray*)activities
{
    if (activities.count == 0)
    {
        return YES;
    }

    OWTActivity* lastActivity = [activities lastObject];

    EWTActivityType lastActivityType = lastActivity.activityType;
    EWTActivityType activityType = activity.activityType;

    // Only the same type activity can be merged
    if (activityType != lastActivityType)
    {
        return NO;
    }

    // Only activities belonging to the same person can be merged
    if (![activity.userID isEqualToString:lastActivity.userID])
    {
        return NO;
    }
    
   
    
    //这里是否是决定显示多少张图片并列的
//    if (![activity.friendsOrFans isEqualToString:lastActivity.friendsOrFans])
//    {
//        return NO;
//    }


    // Only activity happened within certain time period can be merged
    long long timeDiffSeconds = activity.timestamp - lastActivity.timestamp;
    if (llabs(timeDiffSeconds) > 60)
    {
        return NO;
    }

    switch (activityType)
    {
        case nWTActivityTypeUPLOAD:
        {
            // At most 9 UPLOAD activites are merged
            if (activities.count >= 9) { return NO; }

            return YES;
        }
        case nWTActivityTypeLIKE:
        {
            // Only when LIKE activities are refering to the same user's asset can they be merged
            if (![activity.subjectUserID isEqualToString:lastActivity.subjectUserID])
            {
                return NO;
            }

            // At most 9 LIKE activites are merged
            if (activities.count >= 9) { return NO; }

            return YES;
        }
        case nWTActivityTypeCOMMENT:
        {
            // Only when COMMENT activities are refering to the same user's asset can they be merged
            if (![activity.subjectUserID isEqualToString:lastActivity.subjectUserID])
            {
                return NO;
            }

            // At most 9 COMMENT activites are merged
            if (activities.count >= 9) { return NO; }

            // If there's already on activity refering to this activity's asset, it cannot be merged.
            // Must start a new activity. Otherwise we will see duplicated asset in one MergedActivity.
            for (OWTActivity* existingActivity in activities)
            {
                if ([existingActivity.subjectAssetID isEqualToString:activity.subjectAssetID])
                {
                    return NO;
                }
            }

            return YES;
        }
        case nWTActivityTypeFOLLOW:
        {
            // At most 9 COMMENT activites are merged
            if (activities.count >= 16) { return NO; }

            return YES;
        }
        default:
            return NO;
    }
}

@end
