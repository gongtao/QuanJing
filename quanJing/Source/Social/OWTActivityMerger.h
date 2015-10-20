//
//  OWTActivityMerger.h
//  Weitu
//
//  Created by Su on 6/11/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWTActivity.h"
#import "OWTMergedActivity.h"

@interface OWTActivityMerger : NSObject

- (NSArray*)mergeActivities:(NSArray*)activities;

@end
