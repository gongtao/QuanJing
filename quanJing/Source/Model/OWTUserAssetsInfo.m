//
//  OWTUserAssetsInfo.m
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUserAssetsInfo.h"
#import "OWTAssetManager.h"
#import "OWTAsset.h"

@implementation OWTUserAssetsInfo

- (void)mergeWithData:(OWTUserAssetsInfoData*)assetsInfoData
{
    AssertTR (assetsInfoData != nil);

    if (assetsInfoData.publicAssetNum != nil)
    {
        _publicAssetNum = assetsInfoData.publicAssetNum.integerValue;
    }

    if (assetsInfoData.privateAssetNum != nil)
    {
        _privateAssetNum = assetsInfoData.privateAssetNum.integerValue;
    }

    if (assetsInfoData.lightbox != nil)
    {
        _lightbox = assetsInfoData.lightbox.integerValue;
    }
    
    if (assetsInfoData.likedAssetNum != nil)
    {
        _likedAssetNum = assetsInfoData.likedAssetNum.integerValue;
    }
    
    if (assetsInfoData.downloadedAssetNum != nil)
    {
        _downloadedAssetNum = assetsInfoData.downloadedAssetNum.integerValue;
    }

    if (assetsInfoData.sharedAssetNum != nil)
    {
        _sharedAssetNum = assetsInfoData.sharedAssetNum.integerValue;
    }
}

@end
