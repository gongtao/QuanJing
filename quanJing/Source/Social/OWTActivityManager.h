//
//  OWTActivityManager.h
//  Weitu
//
//  Created by Su on 6/3/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWTActivityManager : NSObject


- (void)refreshWithSuccess:(void (^)(NSArray* mergedActivities))success
                   failure:(void (^)(NSError* error))failure with:(NSInteger)page;

- (void)loadMoreWithSuccess:(void (^)(NSArray* mergedActivities))success
                    failure:(void (^)(NSError* error))failure;
@end
