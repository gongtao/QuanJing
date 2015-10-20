//
//  OWTUserAssetsInfo.h
//  Weitu
//
//  Created by Su on 6/15/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWTUserAssetsInfoData : NSObject

@property (nonatomic, copy) NSNumber* publicAssetNum;
@property (nonatomic, copy) NSNumber* privateAssetNum;
@property (nonatomic, copy) NSNumber* likedAssetNum;
@property (nonatomic, copy) NSNumber* downloadedAssetNum;
@property (nonatomic, copy) NSNumber* sharedAssetNum;
@property (nonatomic, copy) NSNumber* lightbox;

@property (nonatomic, copy) NSArray* assetsIDs;
@property (nonatomic, copy) NSArray* likedAssetIDs;
@property (nonatomic, copy) NSArray* downloadedAssetIDs;
@property (nonatomic, copy) NSArray* sharedAssetIDs;

@end
