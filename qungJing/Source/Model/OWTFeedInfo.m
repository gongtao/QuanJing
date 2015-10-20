//
//  OWTFeedInfo.m
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTFeedInfo.h"

@implementation OWTFeedInfo

- (id)initWithFeedID:(NSString*)feedID
              nameZH:(NSString*)nameZH
              nameEN:(NSString*)nameEN
      lastUpdateTime:(long)lastUpdateTime
          generation:(long)generation
{
    self = [super init];
    if (self != nil)
    {
        _feedID = feedID;
        _nameZH = nameZH;
        _nameEN = nameEN;
        _lastUpdateTime = lastUpdateTime;
        _generation = generation;
    }
    return self;
}

@end
