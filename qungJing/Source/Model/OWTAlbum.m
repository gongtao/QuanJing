//
//  OWTAlbum.m
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTAlbum.h"
#import "OWTAssetManager.h"
#import "OWTServerError.h"
#import "OWTUserManager.h"
#import "OWTAsset.h"

@implementation OWTAlbum

- (void)mergeWithData:(OWTAlbumData*)albumData
{
    if (albumData == nil)
    {
        return;
    }
    
    if (albumData.albumID != nil)
    {
        if (_albumID == nil)
        {
            _albumID = albumData.albumID;
        }
        else
        {
            if (![_albumID isEqualToString:albumData.albumID])
            {
                AssertTR(!"AlbumID does not match while merging.");
                return;
            }
        }
    }
    
    if (albumData.albumName != nil)
    {
        _albumName = albumData.albumName;
    }
    
    if (albumData.albumDescription != nil)
    {
        _albumDescription = albumData.albumDescription;
    }
    
    if (albumData.categoryID != nil)
    {
        _categoryID = albumData.categoryID;
    }
    
    if (albumData.albumCoverAssetID != nil)
    {
        _albumCoverAssetID = albumData.albumCoverAssetID;
    }
}

- (void)mergeWithAssets:(NSArray*)assets dropOld:(BOOL)dropOld
{
    if (dropOld)
    {
        _assets = [NSMutableOrderedSet orderedSetWithArray:assets];
    }
    else
    {
        if (_assets == nil)
        {
            _assets = [NSMutableOrderedSet orderedSetWithArray:assets];
        }
        else
        {
            [_assets addObjectsFromArray:assets];
        }
    }
}

- (void)refreshWithSuccess:(void (^)())success
                   failure:(void (^)(NSError* error))failure
{
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om getObject:nil
             path:[NSString stringWithFormat:@"users/%@/albums/%@", self.userID, self.albumID]
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
              
              OWTAlbumData* albumData = resultObjects[@"album"];
              if (albumData == nil)
              {
                  if (failure != nil)
                  {
                      failure([[OWTServerError unknownError] toNSError]);
                  }
                  return;
              }
              
              NSArray* relatedAssetDatas = resultObjects[@"relatedAssets"];
              if (relatedAssetDatas == nil)
              {
                  if (failure != nil)
                  {
                      failure([[OWTServerError unknownError] toNSError]);
                  }
                  return;
              }
              
              [GetAssetManager() registerAssetDatas:relatedAssetDatas];
              
              NSArray* relatedUserDatas = resultObjects[@"relatedUsers"];
              if (relatedUserDatas == nil)
              {
                  if (failure != nil)
                  {
                      failure([[OWTServerError unknownError] toNSError]);
                  }
                  return;
              }
              [GetUserManager() registerUserDatas:relatedUserDatas];
              
              [self mergeWithData:albumData];
              
              if (success != nil)
              {
                  success();
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


- (void)refreshAssetsWithSuccess:(void (^)())success
                         failure:(void (^)(NSError*))failure
{
    [self fetchAssetsStartIndex:0
                          count:50
                        dropOld:YES
                        success:success
                        failure:failure];
    
    _refreshNeeded = NO;
}

- (void)loadMoreAssetsCount:(NSInteger)count
                    success:(void (^)())success
                    failure:(void (^)(NSError*))failure
{
    NSInteger startIndex;
    if (_assets != nil)
    {
        startIndex = _assets.count;
    }
    else
    {
        startIndex = 0;
    }
    
    [self fetchAssetsStartIndex:startIndex
                          count:50
                        dropOld:NO
                        success:success
                        failure:failure];
}

- (void)fetchAssetsStartIndex:(NSInteger)startIndex
                        count:(NSInteger)count
                      dropOld:(BOOL)dropOld
                      success:(void (^)())success
                      failure:(void (^)(NSError*))failure
{
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om getObject:nil
             path:[NSString stringWithFormat:@"users/%@/albums/%@/assets", self.userID, self.albumID]
       parameters:@{ @"startIndex" : [NSString stringWithFormat:@"%d", startIndex],
                     @"count" : [NSString stringWithFormat:@"%d", count] }
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
              
              OWTAlbumData* albumData = resultObjects[@"album"];
              if (albumData == nil)
              {
                  if (failure != nil)
                  {
                      failure([[OWTServerError unknownError] toNSError]);
                  }
                  return;
              }
              
              NSArray* assetDatas = resultObjects[@"assets"];
              if (assetDatas == nil)
              {
                  if (failure != nil)
                  {
                      failure([[OWTServerError unknownError] toNSError]);
                  }
                  return;
              }
              
              NSArray* assets = [GetAssetManager() registerAssetDatasAndReturnAssets:assetDatas];
              
              NSArray* relatedUserDatas = resultObjects[@"relatedUsers"];
              if (relatedUserDatas == nil)
              {
                  if (failure != nil)
                  {
                      failure([[OWTServerError unknownError] toNSError]);
                  }
                  return;
              }
              [GetUserManager() registerUserDatas:relatedUserDatas];
              
              [self mergeWithData:albumData];
              [self mergeWithAssets:assets dropOld:dropOld];
              
              if (success != nil)
              {
                  success();
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
    
    _refreshNeeded = NO;
}

@end
