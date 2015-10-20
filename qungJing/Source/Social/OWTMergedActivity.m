//
//  OWTMergedActivity.m
//  Weitu
//
//  Created by Su on 6/11/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTMergedActivity.h"

@implementation OWTMergedActivity

- (instancetype)initWithActivities:(NSArray*)activities
{
    self = [super init];
    if (self != nil)
    {
        if (activities != nil && activities.count > 0)
        {
            OWTActivity* firstActivity = [activities firstObject];
            _timestamp = [NSDate dateWithTimeIntervalSince1970:firstActivity.timestamp];
            
            //
            _friendsOrFans = firstActivity.friendsOrFans;
            //
            _activityType = firstActivity.activityType;
            _userID = firstActivity.userID;

            switch (_activityType)
            {
                case nWTActivityTypeUPLOAD:
                {
                    [self setSubjectAssetIDsWithActivities:activities];
                    break;
                }

                case nWTActivityTypeLIKE:
                {
                    NSString* subjectUserID = firstActivity.subjectUserID;
                    if (subjectUserID != nil)
                    {
                        _subjectUserIDs = [NSOrderedSet orderedSetWithObject:firstActivity.subjectUserID];
                    }
                    else
                    {
                        _subjectUserIDs = [NSOrderedSet orderedSet];
                    }

                    [self setSubjectAssetIDsWithActivities:activities];
                    break;
                }

                case nWTActivityTypeCOMMENT:
                {
                    NSString* subjectUserID = firstActivity.subjectUserID;
                    if (subjectUserID != nil)
                    {
                        _subjectUserIDs = [NSOrderedSet orderedSetWithObject:firstActivity.subjectUserID];
                    }
                    else
                    {
                        _subjectUserIDs = [NSOrderedSet orderedSet];
                    }

                    [self setSubjectAssetIDsWithActivities:activities];
                    break;
                }

                case nWTActivityTypeFOLLOW:
                {
                    [self setSubjectUserIDsFromActivities:activities];
                    break;
                }

                default:
                    NSAssert(false, @"Should not reach here.");
                    break;
            }
        }
    }
    return self;
}

- (void)setSubjectAssetIDsWithActivities:(NSArray*)activities
{
    NSMutableOrderedSet* tmpSubjectAssetIDs = [NSMutableOrderedSet orderedSetWithCapacity:activities.count];

    for (OWTActivity* activity in activities)
    {
        NSString* assetID = activity.subjectAssetID;
        if (assetID != nil)
        {
            [tmpSubjectAssetIDs addObject:assetID];
        }
    }

    _subjectAssetIDs = tmpSubjectAssetIDs;
}

- (void)setSubjectUserIDsFromActivities:(NSArray*)activities
{
    NSMutableOrderedSet* tmpSubjectUserIDs = [NSMutableOrderedSet orderedSetWithCapacity:activities.count];
    for (OWTActivity* activity in activities)
    {
        NSString* subjectUserID = activity.subjectUserID;
        if (subjectUserID != nil)
        {
            [tmpSubjectUserIDs addObject:subjectUserID];
        }
    }
    _subjectUserIDs = tmpSubjectUserIDs;
}

@end
