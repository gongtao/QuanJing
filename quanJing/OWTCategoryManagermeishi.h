//
//  OWTAssetCategoryManager.h
//  Weitu
//
//  Created by Su on 5/8/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWTCategory.h"

@interface OWTCategoryManagermeishi : NSObject
@property (copy)NSString *keyPath;

@property (nonatomic, strong, readonly) NSArray* categories;
@property (nonatomic, assign) BOOL isRefreshNeeded;

- (BOOL)isCategorySubscribedByCurrentUser:(OWTCategory*)category;

- (BOOL)refreshIfNeededCategoriesWithSuccess:(void(^)())success
                                     failure:(void(^)(NSError* error))failure;

- (void)refreshCategoriesWithSuccess:(void(^)())success
                             failure:(void(^)(NSError* error))failure;

- (void)modifyCategory:(OWTCategory*)category
          subscription:(BOOL)isSubscribing
               success:(void(^)())success
               failure:(void(^)(NSError* error))failure;

@end
