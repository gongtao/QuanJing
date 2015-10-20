//
//  OWTAssetPageView.m
//  WhiteCloud
//
//  Created by Su on 3/6/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTAssetPageView.h"

@implementation OWTAssetPageView

- (void)prepareForReuse
{
    _pageIndex = -1;
    _asset = nil;
    _imageUrl =nil;
}

- (void)setAsset:(OWTAsset*)asset
{
    if (asset != _asset)
    {
        _asset = asset;
        [self assetDidChange];
    }
    
}
- (void)setImageUrl:(NSString *)imageUrl
{
    if (imageUrl != _imageUrl)
    {
        _imageUrl = imageUrl;
        [self assetDidChange];
    }
    
}


- (void)assetDidChange
{
    
}

- (void)pageWillBeginSlide
{
    
}

- (void)pageWillSlideOut
{
    
}

- (void)pageDidSlideOut
{
    
}

@end
