//
//  OWTUserAssetsInfo.h
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUserAssetsInfoData.h"

@interface OWTUserAssetsInfo : NSObject

@property (nonatomic, assign) NSInteger publicAssetNum;
@property (nonatomic, assign) NSInteger privateAssetNum;
@property (nonatomic, assign) NSInteger likedAssetNum;
@property (nonatomic, assign) NSInteger downloadedAssetNum;
@property (nonatomic, assign) NSInteger sharedAssetNum;
@property (nonatomic, assign) NSInteger lightbox;

@property (nonatomic, strong) NSMutableOrderedSet* assets;
@property (nonatomic, strong) NSMutableOrderedSet* likedAssets;
@property (nonatomic, strong) NSMutableOrderedSet* downloadedAssets;
@property (nonatomic, strong) NSMutableOrderedSet* sharedAssets;

- (void)mergeWithData:(OWTUserAssetsInfoData*)assetsInfoData;

@end
