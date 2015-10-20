//
//  OWTSearchManager.m
//  Weitu
//
//  Created by Su on 8/22/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTSearchManager.h"
#import "OWTServerError.h"
#import "OWTAssetManager.h"

@implementation OWTSearchManager

- (void)searchAssetsWithKeyword:(NSString*)keyword
                        success:(void (^)(NSArray* assets))success
                        failure:(void (^)(NSError* error))failure
{
    [self searchAssetsWithKeyword:keyword
                       startIndex:0
                            count:50
                          success:success
                          failure:failure];
}

- (void)searchAssetsWithKeyword:(NSString*)keyword
                     startIndex:(NSInteger)startIndex
                          count:(NSInteger)count
                        success:(void (^)(NSArray* assets))success
                        failure:(void (^)(NSError* error))failure
{
    NSString* url = [NSString stringWithFormat:@"assets/search1/%@", keyword];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* userPhoneName = [[UIDevice currentDevice] name];
    NSLog(@"手机别名: %@", userPhoneName);
    
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om getObject:nil
             path:url
       parameters:@{ @"startIndex" : [NSString stringWithFormat:@"%d", startIndex],
                     @"count" : [NSString stringWithFormat:@"%d", count],
                     @"pn" : userPhoneName}
          success:^(RKObjectRequestOperation* o, RKMappingResult* result) {
              [o logResponse];
              
              NSDictionary* resultObjects = result.dictionary;
              OWTServerError* error = resultObjects[@"error"];
              if (error != nil)
              {
                  if (failure != nil)
                  {
                      failure([error toNSError]);
                  }
                  return;
              }
              
              NSArray* assetDatas = resultObjects[@"assets"];
              if (assetDatas == nil)
              {
                  if (failure != nil)
                  {
                      failure([error toNSError]);
                  }
                  return;
              }
              
              NSArray* assets = [GetAssetManager() registerAssetDatasAndReturnAssets:assetDatas];
              
              if (success != nil)
              {
                  success(assets);
              }
          }
          failure:^(RKObjectRequestOperation* o, NSError* error) {
              [o logResponse];
              
              if (failure != nil)
              {
                  failure(error);
              }
          }
     ];
}

@end
