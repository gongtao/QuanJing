//
//  OWTUserFellowshipInfo.h
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUserFellowshipInfoData.h"

@interface OWTUserFellowshipInfo : NSObject

@property (nonatomic, assign) NSInteger followingNum;
@property (nonatomic, assign) NSInteger followerNum;

@property (nonatomic, strong) NSMutableSet* followingUserIDs;

@property (nonatomic, strong) NSMutableOrderedSet* followingUsers;
@property (nonatomic, strong) NSMutableOrderedSet* followerUsers;

- (void)mergeWithData:(OWTUserFellowshipInfoData*)fellowshipInfoData;

@end
