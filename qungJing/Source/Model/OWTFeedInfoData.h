//
//  OWTFeedInfo.h
//  Weitu
//
//  Created by Su on 3/31/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWTFeedInfoData : NSObject

@property (nonatomic, copy) NSString* feedID;
@property (nonatomic, copy) NSString* nameZH;
@property (nonatomic, copy) NSString* nameEN;
@property (nonatomic, copy) NSNumber* lastUpdateTime;
@property (nonatomic, copy) NSNumber* generation;

@end
