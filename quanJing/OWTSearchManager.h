//
//  OWTSearchManager.h
//  Weitu
//
//  Created by Su on 8/22/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWTSearchManager : NSObject

- (void)searchAssetsWithKeyword:(NSString*)keyword
                        success:(void (^)(NSArray* assets))success
                        failure:(void (^)(NSError* error))failure;

- (void)searchAssetsWithKeyword:(NSString*)keyword
                     startIndex:(NSInteger)startIndex
                          count:(NSInteger)count
                        success:(void (^)(NSArray* assets))success
                        failure:(void (^)(NSError* error))failure;

@end
