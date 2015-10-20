//
//  OWTAssetManager.h
//  Weitu
//
//  Created by Su on 3/10/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWTAssetManager : NSObject

//- (void)uploadImageDatas:(NSArray*)imageDatas
//                 caption:(NSString*)caption
//               isPrivate:(BOOL)isPrivate
//         belongingAlbums:(NSSet*)belongingAlbums
//                progress:(void (^)(NSInteger, NSInteger))progress
//                 success:(void (^)())success
//                 failure:(void (^)(NSError*))failure;

- (void)uploadImageDatas:(NSArray*)imageDatas
                 caption:(NSString*)caption
               isPrivate:(BOOL)isPrivate
              islocation:(NSString *)location
              iskeywords:(NSString *)keywords
         belongingAlbums:(NSSet*)belongingAlbums
                progress:(void (^)(NSInteger, NSInteger))progress
                 success:(void (^)())success
                 failure:(void (^)(NSError*))failure;

- (void)uploadImageData:(NSData*)imageData
                caption:(NSString*)caption
              isPrivate:(BOOL)isPrivate
        belongingAlbums:(NSSet*)belongingAlbums
                success:(void (^)())success
                failure:(void (^)(NSError*))failure;
- (void)uploadImageDatas1:(NSArray*)imageDatas
                 caption:(NSString*)caption
               isPrivate:(BOOL)isPrivate
         belongingAlbums:(NSSet*)belongingAlbums
                progress:(void (^)(NSInteger, NSInteger))progress
                 success:(void (^)())success
                  failure:(void (^)(NSError*))failure;
//增加的IsNew参数
- (void)uploadImageData:(NSData*)imageData
                caption:(NSString*)caption
              isPrivate:(BOOL)isPrivate
                 degree:(NSInteger)degree
                  isNew:(NSString*)IsNew
        belongingAlbums:(NSSet*)albums
                success:(void (^)())success
                failure:(void (^)(NSError*))failure;

- (OWTAsset*)registerAssetData:(OWTAssetData*)assetData;
- (void)registerAssetDatas:(NSArray *)assets;
- (NSMutableArray*)registerAssetDatasAndReturnAssets:(NSArray *)assetDatas;

- (OWTAsset*)getAssetWithID:(NSString*)assetID;

- (void)updateAsset:(OWTAsset*)asset
        withCaption:(NSString*)caption
          isPrivate:(BOOL)isPrivate
         islocation:(NSString *)location
         iskeywords:(NSString *)keywords
albums:(NSSet*)albums
            success:(void (^)())success
            failure:(void (^)(NSError* error))failure;


- (void)updateAsset:(OWTAsset*)asset
        withCaption:(NSString*)caption
          isPrivate:(BOOL)isPrivate
             albums:(NSSet*)albums
            success:(void (^)())success
            failure:(void (^)(NSError* error))failure;



- (void)updateAsset:(OWTAsset*)asset
    belongingAlbums:(NSSet*)albums
            success:(void (^)())success
            failure:(void (^)(NSError* error))failure;

- (void)deleteAsset:(OWTAsset*)asset
            success:(void (^)())success
            failure:(void (^)(NSError* error))failure;

- (void)queryBelongingAlbumsForAsset:(OWTAsset*)asset
                             success:(void (^)(NSArray* albums))success
                             failure:(void (^)(NSError* error))failure;

- (void)queryRelatedAssetsForAsset:(OWTAsset*)asset
                           success:(void (^)())success
                           failure:(void (^)(NSError* error))failure;

- (void)reportInappropriateAsset:(OWTAsset*)asset
                         success:(void (^)())success
                         failure:(void (^)(NSError* error))failure;
@property(nonatomic,copy)NSString *gameId;
@end
