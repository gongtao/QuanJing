//
//  OWTImageInfo.h
//  Weitu
//
//  Created by Su on 5/9/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface OWTImageInfo : NSObject

@property (nonatomic, copy) NSString* url;
@property (nonatomic, copy) NSString* smallURL;
@property (nonatomic, copy) NSString* primaryColorHex;
@property (nonatomic, strong, readonly) UIColor* primaryColor;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, readonly) CGSize imageSize;
@property (nonatomic, readonly) NSString* thumbnailURL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) ALAsset *asset;

@property (nonatomic, assign) int degree;

@end
