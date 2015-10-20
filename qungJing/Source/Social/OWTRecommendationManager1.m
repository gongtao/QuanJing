//
//  OWTRecommendationManager.m
//  Weitu
//
//  Created by Su on 8/18/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTRecommendationManager1.h"
#import "OWTServerError.h"
#import "OWTUserManager.h"
#import "OWTAssetManager.h"
#import "OWTAsset.h"

@implementation OWTRecommendationManager1

- (void)fetchRecommendedUsersWithSuccess1:(void (^)(NSArray* users, NSDictionary* recommendedAssetsByUserID))success
                                 failure:(void (^)(NSError*))failure
{
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om getObject:nil
             path:@"recommendation/users"
       parameters:nil
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

              /*
               * 1. Get all recommended users
               */
              NSArray* userDatas = resultObjects[@"users"];
              if (userDatas == nil)
              {
                  if (failure != nil)
                  {
                      failure(MakeError(kWTErrorGeneral));
                  }
                  return;
              }
              NSArray* users = [GetUserManager() registerUserDatasAndReturnUsers:userDatas];

              /*
               * 2. Get recommended user asset datas
               */
              NSArray* recommendedUserAssetDatas = resultObjects[@"recommendedUserAssets"];
              if (recommendedUserAssetDatas == nil)
              {
                  if (failure != nil)
                  {
                      failure(MakeError(kWTErrorGeneral));
                  }
                  return;
              }
              
              OWTAssetManager* am = GetAssetManager();
              NSArray* recommendedUserAssets = [am registerAssetDatasAndReturnAssets:recommendedUserAssetDatas];

              NSMutableDictionary* recommendedAssetsByUserID = [NSMutableDictionary dictionary];
              for (OWTAsset* asset in recommendedUserAssets)
              {
                  NSString* userID = asset.ownerUserID;
                  NSMutableArray* assets = recommendedAssetsByUserID[userID];
                  if (assets == nil)
                  {
                      assets = [NSMutableArray array];
                      [recommendedAssetsByUserID setObject:assets forKey:userID];
                  }
                  [assets addObject:asset];
              }

              NSArray* relatedUserDatas = resultObjects[@"relatedUsers"];
              if (relatedUserDatas == nil)
              {
                  if (failure != nil)
                  {
                      failure(MakeError(kWTErrorGeneral));
                  }
                  return;
              }

              [GetUserManager() registerUserDatas:relatedUserDatas];

              if (success != nil)
              {
                  success(users, recommendedAssetsByUserID);
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
