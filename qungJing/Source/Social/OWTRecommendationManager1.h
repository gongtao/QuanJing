//
//  OWTRecommendationManager.h
//  Weitu
//
//  Created by Su on 8/18/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWTRecommendationManager1 : NSObject

- (void)fetchRecommendedUsersWithSuccess:(void (^)(NSArray* users, NSDictionary* recommendedAssetsByUser))success
                                 failure:(void (^)(NSError*))failure;

@end
