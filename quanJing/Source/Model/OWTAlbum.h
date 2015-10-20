//
//  OWTAlbum.h
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTAlbumData.h"

@interface OWTAlbum : NSObject

@property (nonatomic, copy) NSString* userID;

@property (nonatomic, copy) NSString* albumID;
@property (nonatomic, copy) NSString* albumName;
@property (nonatomic, copy) NSString* albumDescription;
@property (nonatomic, copy) NSString* categoryID;
@property (nonatomic, copy) NSString* albumCoverAssetID;
@property (nonatomic, strong) NSMutableOrderedSet* assets;
@property (nonatomic, assign) BOOL refreshNeeded;

- (void)mergeWithData:(OWTAlbumData*)albumData;

- (void)refreshAssetsWithSuccess:(void (^)())success
                         failure:(void (^)(NSError* error))failure;

- (void)loadMoreAssetsCount:(NSInteger)count
                    success:(void (^)())success
                    failure:(void (^)(NSError*))failure;

@end
