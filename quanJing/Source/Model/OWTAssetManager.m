//
//  OWTAssetManager.m
//  Weitu
//
//  Created by Su on 3/10/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTAssetManager.h"
#import "OWTAuthManager.h"
#import "OWTUserManager.h"
#import "OWTUser.h"
#import "OWTServerError.h"
#import "OWTAsset.h"
#import "OStringArray.h"


#import "OWTimageData.h"
@interface OWTAssetManager()
{
    
}

@property (nonatomic, strong) NSMutableDictionary* assetsByID;

@end

@implementation OWTAssetManager

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _assetsByID = [NSMutableDictionary dictionary];
    }
    return self;
}

- (OWTAsset*)registerAssetData:(OWTAssetData*)assetData
{
    if (assetData == nil)
    {
        return nil;
    }
    
    NSString* assetID = assetData.assetID;
    if (assetID == nil)
    {
        return nil;
    }
    
    OWTAsset* asset = [_assetsByID objectForKey:assetID];
    if (asset == nil)
    {
        asset = [[OWTAsset alloc] init];
        [_assetsByID setObject:asset forKey:assetID];
    }
    
    [asset mergeWithData:assetData];
    
    return asset;
}

- (void)registerAssetDatas:(NSArray *)assets
{
    for (OWTAssetData* assetData in assets)
    {
        [self registerAssetData:assetData];
    }
}

- (NSMutableArray*)registerAssetDatasAndReturnAssets:(NSArray *)assetDatas
{
    NSMutableArray* assets = [NSMutableArray array];
    for (OWTAssetData* assetData in assetDatas)
    {
        OWTAsset* asset = [self registerAssetData:assetData];
        [assets addObject:asset];
    }
    return assets;
}

- (OWTAsset*)getAssetWithID:(NSString*)assetID
{
    return [_assetsByID objectForKey:assetID];
    
}


- (void)uploadImageDatas1:(NSArray*)imageDatas
                  caption:(NSString*)caption
                isPrivate:(BOOL)isPrivate
          belongingAlbums:(NSSet*)belongingAlbums
                 progress:(void (^)(NSInteger, NSInteger))progress
                  success:(void (^)())success
                  failure:(void (^)(NSError*))failure
{
    OWTAuthManager* am = GetAuthManager();
    if (!am.isAuthenticated)
    {
        if (failure != nil)
        {
            failure(MakeError(kWTErrorAuthFailed));
            return;
        }
    }
    
    NSMutableArray* pendingImageDatas = [NSMutableArray arrayWithArray:imageDatas];
    
    dispatch_queue_t dq = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(dq, ^{
        int i=0;
        while (pendingImageDatas.count > 0)
        {
            NSData* imageData = [pendingImageDatas firstObject];
            NSString *isNewStr = [[NSString alloc]init];
            
            NSLog(@"11111111111111111%d",i);
            if (i==0) {
                isNewStr =@"1";
            }
            else
                isNewStr =@"0";
            i++;
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            
            __block BOOL failed = NO;
            __block NSError* uploadError = nil;
            
            [self uploadImageData:imageData
                          caption:caption
                        isPrivate:isPrivate
                            isNew:isNewStr
                  belongingAlbums:belongingAlbums
                          success:^{
                              dispatch_semaphore_signal(sema);
                          }
                          failure:^(NSError* error) {
                              uploadError = error;
                              failed = YES;
                              dispatch_semaphore_signal(sema);
                          }];
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            
            if (failed)
            {
                if (failure != nil)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{ failure(uploadError); });
                    return;
                }
            }
            else
            {
                [pendingImageDatas removeObjectAtIndex:0];
                
                if (progress != nil)
                {
                    NSInteger uploadedImageNum = imageDatas.count - pendingImageDatas.count;
                    NSInteger totalImageNum = imageDatas.count;
                    dispatch_async(dispatch_get_main_queue(), ^{ progress(uploadedImageNum, totalImageNum); });
                }
                
                if (pendingImageDatas.count == 0)
                {
                    if (success != nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{ success(); });
                    }
                }
            }
        }
    });
}

- (void)uploadImageData:(NSData*)imageData
                caption:(NSString*)caption
              isPrivate:(BOOL)isPrivate
                  isNew:(NSString*)IsNew
        belongingAlbums:(NSSet*)albums
                success:(void (^)())success
                failure:(void (^)(NSError*))failure
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    params[@"action"] = @"upload";
    if (caption != nil)
    {
        params[@"caption"] = caption;
    }
    params[@"is_private"] = isPrivate ? @"true" : @"false";
    //
    //添加isNew参数
    if ([IsNew isEqualToString:@"1"]) {
        params[@"isNew"] =@"1";
    }
    else
        params[@"isNew"] = @"0";
    NSLog(@"2222222222222222%@",params[@"isNew"]);
    NSMutableString* albumIDsList = nil;
    if (albums != nil)
    {
        albumIDsList = [NSMutableString string];
        for (OWTAlbum* album in albums)
        {
            if (albumIDsList.length > 0)
            {
                [albumIDsList appendString:@","];
            }
            [albumIDsList appendString:album.albumID];
        }
        params[@"album_ids"] = albumIDsList;
    }
    
    NSMutableURLRequest* request;
    
    RKObjectManager* om = [RKObjectManager sharedManager];
    request = [om multipartFormRequestWithObject:nil
                                          method:RKRequestMethodPOST
                                            path:@"assets"
                                      parameters:params
                       constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                           [formData appendPartWithFileData:imageData
                                                       name:@"file"
                                                   fileName:@"uploading-image.jpg"
                                                   mimeType:@"application/octet-stream"];
                       }];
    
    RKObjectRequestOperation* operation;
    operation = [om objectRequestOperationWithRequest:request
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
                                                  
                                                  if (success != nil)
                                                  {
                                                      success();
                                                  }
                                              }
                                              failure:^(RKObjectRequestOperation* o, NSError* error) {
                                                  if (failure != nil)
                                                  {
                                                      failure(error);
                                                  }
                                              }];
    
    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation];
}

//这里添加图片的翻转角度
- (void)uploadImageDatas:(NSArray*)imageDatas
                 caption:(NSString*)caption
               isPrivate:(BOOL)isPrivate
              islocation:(NSString *)location
              iskeywords:(NSString *)keywords
         belongingAlbums:(NSSet*)belongingAlbums
                progress:(void (^)(NSInteger, NSInteger))progress
                 success:(void (^)())success
                 failure:(void (^)(NSError*))failure
{
    OWTAuthManager* am = GetAuthManager();
    if (!am.isAuthenticated)
    {
        if (failure != nil)
        {
            failure(MakeError(kWTErrorAuthFailed));
            return;
        }
    }
    
    NSMutableArray* pendingImageDatas = [NSMutableArray arrayWithArray:imageDatas];
    
    dispatch_queue_t dq = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(dq, ^{
        int i=0;
        while (pendingImageDatas.count > 0)
        {
            OWTimageData* imageData1 = [pendingImageDatas firstObject];
            NSData* imageData = imageData1.imageData;
            
            NSString *isNewStr = [[NSString alloc]init];
            
            NSLog(@"11111111111111111%d",i);
            if (i==0) {
                isNewStr =@"1";
            }
            else
                isNewStr =@"0";
            i++;
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            
            __block BOOL failed = NO;
            __block NSError* uploadError = nil;
            //遍历图片的角度
            
            int degree =0;
            
            //把orientation转化成角度
            NSLog(@"bbbbbbbbbbbbbbbbbbbbbbbbl%d",imageData1.orientation);
            
            
            
            //  6          正竖
            
            //  8          倒树
            
            //  1           左转 横   摄像键在右
            
            //  3           右转 横   摄像键在左
            
            if (imageData1.orientation==0) {
                degree=0;
            }
            
            
            
            
            
            
            
            
            
            if (imageData1.orientation ==1||imageData1.orientation ==2) {
                
                degree =0;
                
            }
        
            if (imageData1.orientation ==8||imageData1.orientation ==7) {
                
                degree =270;
                
            }
            
            if (imageData1.orientation ==3||imageData1.orientation ==4) {
                
                degree =180;
                
            }
            
            if (imageData1.orientation ==6||imageData1.orientation ==5) {
                
                degree =90;
                
            }
            
           
            
            
            
            
            
            [self uploadImageData:imageData
                          caption:caption
                        isPrivate:isPrivate
             islocation:location
                       iskeywords:keywords
                           degree:degree
             isNew:isNewStr
                  belongingAlbums:belongingAlbums
                          success:^{
                              dispatch_semaphore_signal(sema);
                          }
                          failure:^(NSError* error) {
                              uploadError = error;
                              failed = YES;
                              dispatch_semaphore_signal(sema);
                          }];
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            
            if (failed)
            {
                if (failure != nil)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{ failure(uploadError); });
                    return;
                }
            }
            else
            {
                [pendingImageDatas removeObjectAtIndex:0];
                
                if (progress != nil)
                {
                    NSInteger uploadedImageNum = imageDatas.count - pendingImageDatas.count;
                    NSInteger totalImageNum = imageDatas.count;
                    dispatch_async(dispatch_get_main_queue(), ^{ progress(uploadedImageNum, totalImageNum); });
                }
                
                if (pendingImageDatas.count == 0)
                {
                    if (success != nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{ success(); });
                    }
                }
            }
        }
    });
}

- (void)uploadImageData:(NSData*)imageData
                caption:(NSString*)caption
              isPrivate:(BOOL)isPrivate
             islocation:(NSString *)location
             iskeywords:(NSString *)keywords
                 degree:(NSInteger)degree
isNew:(NSString*)IsNew
        belongingAlbums:(NSSet*)albums
                success:(void (^)())success
                failure:(void (^)(NSError*))failure
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    params[@"action"] = @"upload";
    if (caption != nil)
    {
        params[@"caption"] = caption;
    }
    if (_gameId!=nil) {
        params[@"gameid"]=_gameId;
    }
        params[@"degree"] = [NSString stringWithFormat:@"%d",degree];
   
    params[@"PhoneType"] = @"iphone";
    
    
    params[@"position"] = [NSString stringWithFormat:@"%@",location];
    
    params[@"keywords"] = [NSString stringWithFormat:@"%@",keywords];
    
    params[@"is_private"] = isPrivate ? @"true":@"false";
//
    //添加isNew参数
    if ([IsNew isEqualToString:@"1"]) {
        params[@"isNew"] =@"1";
    }
    else
    params[@"isNew"] = @"0";
     NSLog(@"2222222222222222%@",params[@"isNew"]);
    NSMutableString* albumIDsList = nil;
    if (albums != nil)
    {
        albumIDsList = [NSMutableString string];
        for (OWTAlbum* album in albums)
        {
            if (albumIDsList.length > 0)
            {
                [albumIDsList appendString:@","];
            }
            [albumIDsList appendString:album.albumID];
        }
        params[@"album_ids"] = albumIDsList;
    }

    NSMutableURLRequest* request;
    
    RKObjectManager* om = [RKObjectManager sharedManager];
    request = [om multipartFormRequestWithObject:nil
                                          method:RKRequestMethodPOST
                                            path:@"assets"
                                      parameters:params
                       constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                           [formData appendPartWithFileData:imageData
                                                       name:@"file"
                                                   fileName:@"uploading-image.jpg"
                                                   mimeType:@"application/octet-stream"];
                       }];
    
    RKObjectRequestOperation* operation;
    operation = [om objectRequestOperationWithRequest:request
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
                                                  
                                                  if (success != nil)
                                                  {
                                                      success();
                                                  }
                                              }
                                              failure:^(RKObjectRequestOperation* o, NSError* error) {
                                                  if (failure != nil)
                                                  {
                                                      failure(error);
                                                  }
                                              }];
    
    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation];
}



- (void)updateAsset:(OWTAsset*)asset
        withCaption:(NSString*)caption
          isPrivate:(BOOL)isPrivate
             albums:(NSSet*)albums
            success:(void (^)())success
            failure:(void (^)(NSError* error))failure
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    params[@"action"] = @"modify";
    if (caption != nil)
    {
        params[@"caption"] = caption;
    }
    params[@"is_private"] = isPrivate ? @"true" : @"false";
    
    NSMutableString* albumIDsList = nil;
    if (albums != nil)
    {
        albumIDsList = [NSMutableString string];
        for (OWTAlbum* album in albums)
        {
            if (albumIDsList.length > 0)
            {
                [albumIDsList appendString:@","];
            }
            [albumIDsList appendString:album.albumID];
        }
        params[@"album_ids"] = albumIDsList;
    }
    
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om postObject:nil
              path:[NSString stringWithFormat:@"assets/%@", asset.assetID]
        parameters:params
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
               
               OWTAssetData* assetData = resultObjects[@"asset"];
               if (assetData == nil)
               {
                   if (failure != nil)
                   {
                       failure([error toNSError]);
                   }
                   return;
               }
               
               [asset mergeWithData:assetData];
               
               if (success != nil)
               {
                   success();
               }
           }
           failure:^(RKObjectRequestOperation* o, NSError* error) {
               if (failure != nil)
               {
                   failure(error);
               }
           }];
}





- (void)updateAsset:(OWTAsset*)asset
        withCaption:(NSString*)caption
          isPrivate:(BOOL)isPrivate
         islocation:(NSString *)location
         iskeywords:(NSString *)keywords
             albums:(NSSet*)albums
            success:(void (^)())success
            failure:(void (^)(NSError* error))failure
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    params[@"action"] = @"modify";
    
    if (location != nil)
    {
        params[@"position"] = location;
    }
    if (keywords != nil)
    {
        params[@"keywords"] = keywords;
    }
    
    if (caption != nil)
    {
        params[@"caption"] = caption;
    }
    params[@"is_private"] = isPrivate ?  @"true":@"false";
    
    
    
        params[@"album_ids"] = @"";

    
    
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om postObject:nil
              path:[NSString stringWithFormat:@"assets/%@", asset.assetID]
        parameters:params
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
               
               OWTAssetData* assetData = resultObjects[@"asset"];
               if (assetData == nil)
               {
                   if (failure != nil)
                   {
                       failure([error toNSError]);
                   }
                   return;
               }
               
               [asset mergeWithData:assetData];
               
               if (success != nil)
               {
                   success();
               }
           }
           failure:^(RKObjectRequestOperation* o, NSError* error) {
               if (failure != nil)
               {
                   failure(error);
               }
           }];}

- (void)updateAsset:(OWTAsset*)asset
    belongingAlbums:(NSSet*)albums
            success:(void (^)())success
            failure:(void (^)(NSError* error))failure
{
    
    NSLog(@"1111111111111111111%d",albums.count);
    NSMutableDictionary* params = [NSMutableDictionary dictionary];

    NSMutableString* albumIDsList = nil;
    if (albums != nil)
    {
        albumIDsList = [NSMutableString string];
        for (OWTAlbum* album in albums)
        {
            if (albumIDsList.length > 0)
            {
                [albumIDsList appendString:@","];
            }
            [albumIDsList appendString:album.albumID];
        }
        params[@"album_ids"] = albumIDsList;
    }
    if (albums.count>0) {
        RKObjectManager* om = [RKObjectManager sharedManager];
        [om postObject:nil
                  path:[NSString stringWithFormat:@"assets/%@/albums", asset.assetID]
            parameters:params
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
                   
                   if (success != nil)
                   {
                       success();
                   }
               }
               failure:^(RKObjectRequestOperation* o, NSError* error) {
                   if (failure != nil)
                   {
                       failure(error);
                   }
               }];

    }
    else{
        RKObjectManager* om = [RKObjectManager sharedManager];
        [om postObject:nil
                  path:[NSString stringWithFormat:@"assets/%@/lightbox", asset.assetID]
            parameters:@{ @"action" : @"lightbox"
                           }
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
                   
                   if (success != nil)
                   {
                       success();
                   }
               }
               failure:^(RKObjectRequestOperation* o, NSError* error) {
                   if (failure != nil)
                   {
                       failure(error);
                   }
               }];

    }
}


- (void)deleteAsset:(OWTAsset*)asset
            success:(void (^)())success
            failure:(void (^)(NSError* error))failure
{
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om postObject:nil
              path:[NSString stringWithFormat:@"assets/%@", asset.assetID]
        parameters:@{ @"action": @"delete" }
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

               if (success != nil)
               {
                   success();
               }
           }
           failure:^(RKObjectRequestOperation* o, NSError* error) {
               if (failure != nil)
               {
                   failure(error);
               }
           }];
}

- (void)queryBelongingAlbumsForAsset:(OWTAsset*)asset
                             success:(void (^)(NSArray* albums))success
                             failure:(void (^)(NSError* error))failure
{
    void (^queryBlock)() = ^{
        RKObjectManager* om = [RKObjectManager sharedManager];
        [om getObject:nil
                 path:[NSString stringWithFormat:@"assets/%@/albums", asset.assetID]
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
                  
                  OStringArray* albumIDsStringArray = resultObjects[@"albumIDs"];
                  if (albumIDsStringArray == nil)
                  {
                      if (failure != nil)
                      {
                          failure(MakeError(kWTErrorGeneral));
                      }
                      return;
                  }
                  
                  NSArray* albumIDs = albumIDsStringArray.strings;
                  NSMutableArray* albums = [NSMutableArray arrayWithCapacity:albumIDs.count];
                  for (NSString* albumID in albumIDs)
                  {
                      OWTUserAlbumsInfo* albumsInfo = GetUserManager().currentUser.albumsInfo;
                      OWTAlbum* album = [albumsInfo albumWithID:albumID];
                      if (album != nil)
                      {
                          [albums addObject:album];
                      }
                      else
                      {
                          AssertTR(album != nil);
                      }
                  }
                  
                  if (success != nil)
                  {
                      success(albums);
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
    };
    
    OWTUserManager* um = GetUserManager();
    if (um.currentUser.albumsInfo == nil)
    {
        [um refreshPublicInfoForUser:um.currentUser
                             success:^{
                                 queryBlock();
                             }
                             failure:^(NSError* error) {
                                 if (failure != nil)
                                 {
                                     failure(error);
                                 }
                             }];
    }
    else
    {
        queryBlock();
    }
}

- (void)queryRelatedAssetsForAsset:(OWTAsset*)asset
                           success:(void (^)())success
                           failure:(void (^)(NSError* error))failure
{
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om getObject:nil
             path:[NSString stringWithFormat:@"assets/%@/related_assets", asset.assetID]
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

              NSArray* relatedAssetDatas = resultObjects[@"assets"];
              if (relatedAssetDatas == nil)
              {
                  if (failure != nil)
                  {
                      failure(MakeError(kWTErrorGeneral));
                  }
                  return;
              }
              NSMutableArray* relatedAssets = [GetAssetManager() registerAssetDatasAndReturnAssets:relatedAssetDatas];
              
              [asset mergeWithRelatedAssets:relatedAssets];

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

- (void)reportInappropriateAsset:(OWTAsset*)asset
                         success:(void (^)())success
                         failure:(void (^)(NSError* error))failure
{
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om postObject:nil
              path:[NSString stringWithFormat:@"assets/%@/report", asset.assetID]
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

@end
