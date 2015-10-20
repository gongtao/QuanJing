//
//  OWTImageInfo.m
//  Weitu
//
//  Created by Su on 5/9/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTImageInfo.h"
#import <UIColor-HexString/UIColor+HexString.h>

@implementation OWTImageInfo

@synthesize primaryColor = _primaryColor;

- (CGSize)imageSize
{
    return CGSizeMake(_width, _height);
}

- (void)setPrimaryColorHex:(NSString *)primaryColorHex
{
    _primaryColorHex = primaryColorHex;
    if (primaryColorHex != nil && primaryColorHex.length == 6)
    {
        _primaryColor = [UIColor colorWithHexString:primaryColorHex];
    }
    else
    {
        DDLogError(@"PrimaryColorHex format error: %@", primaryColorHex);
    }
}

- (NSString*)thumbnailURL
{
    if (_smallURL != nil && _smallURL.length > 0)
    {
        return _smallURL;
    }
    else
    {
        return _url;
    }
}

@end
