//
//  OWTUserFellowshipInfo.h
//  Weitu
//
//  Created by Su on 6/15/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWTUserFellowshipInfoData : NSObject

@property (nonatomic, copy) NSNumber* followingNum;
@property (nonatomic, copy) NSNumber* followerNum;

@property (nonatomic, copy) NSArray* followingUserIDs;

@end
