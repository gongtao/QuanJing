//
//  OWTCategoryManagerbaike.h
//  Weitu
//
//  Created by qj-app on 15/9/25.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "OWTCategory.h"

@interface OWTCategoryManagerbaike : NSObject
@property (copy)NSString *keyPath;

@property (nonatomic, strong, readonly) NSArray* categories;
@property(nonatomic,strong,readonly)NSMutableArray *categoriBaike;
@property (nonatomic, assign) BOOL isRefreshNeeded;

- (BOOL)isCategorySubscribedByCurrentUser:(OWTCategory*)category;

- (BOOL)refreshIfNeededCategoriesWithSuccess:(void(^)())success
                                     failure:(void(^)(NSError* error))failure;

- (void)refreshCategoriesWithSuccess:(void(^)())success
                             failure:(void(^)(NSError* error))failure;

- (void)refreshCategoriesBaikeWithSuccess:(void(^)())success
                                  failure:(void(^)(NSError* error))failure;

- (void)modifyCategory:(OWTCategory*)category
          subscription:(BOOL)isSubscribing
               success:(void(^)())success
               failure:(void(^)(NSError* error))failure;

@end
