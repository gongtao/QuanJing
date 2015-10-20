//
//  OWTFeedInfo.h
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWTFeedInfo : NSObject

@property (nonatomic, strong, readonly) NSString* feedID;
@property (nonatomic, strong, readonly) NSString* nameZH;
@property (nonatomic, strong, readonly) NSString* nameEN;
@property (nonatomic, assign, readonly) long lastUpdateTime;
@property (nonatomic, assign, readonly) long generation;

- (id)initWithFeedID:(NSString*)feedID
              nameZH:(NSString*)nameZH
              nameEN:(NSString*)nameEN
      lastUpdateTime:(long)lastUpdateTime
          generation:(long)generation;

@end
