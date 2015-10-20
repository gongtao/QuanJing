//
//  OWTFont.m
//  Weitu
//
//  Created by Su on 4/24/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTFont.h"

@implementation OWTFont

+ (UIFont *)iconFontWithSize:(CGFloat)size
{
#ifndef DISABLE_FONTAWESOME_AUTO_REGISTRATION
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self registerIconFontWithURL:[[NSBundle mainBundle] URLForResource:@"WTFont" withExtension:@"ttf"]];
    });
#endif
    
    UIFont *font = [UIFont fontWithName:@"WTFont" size:size];
    NSAssert(font, @"UIFont object should not be nil, check if the font file is added to the application bundle and you're using the correct font name.");
    return font;
}

+ (instancetype)chatBoxIconWithSize:(CGFloat)size
{
    return [self iconWithCode:@"\uf100" size:size];
}

+ (instancetype)shareAltIconWithSize:(CGFloat)size
{
    return [self iconWithCode:@"\uf259" size:size];
}

+ (instancetype)chatBubbleIconWithSize:(CGFloat)size
{
    return [self iconWithCode:@"\uf101" size:size];
}

+ (instancetype)circleBackIconWithSize:(CGFloat)size
{
    return [self iconWithCode:@"\uf102" size:size];
}

+ (instancetype)circlePlusIconWithSize:(CGFloat)size
{
    return [self iconWithCode:@"\uf103" size:size];
}

+ (instancetype)eyeIconWithSize:(CGFloat)size
{
    return [self iconWithCode:@"\uf104" size:size];
}

+ (instancetype)gearIconWithSize:(CGFloat)size
{
    return [self iconWithCode:@"\uf105" size:size];
}

+ (instancetype)heartIconWithSize:(CGFloat)size
{
    return [self iconWithCode:@"\uf106" size:size];
}

+ (instancetype)homeIconWithSize:(CGFloat)size
{
    return [self iconWithCode:@"\uf107" size:size];
}

+ (instancetype)userIconWithSize:(CGFloat)size
{
    return [self iconWithCode:@"\uf108" size:size];
}

+ (instancetype)cameraIconWithSize:(CGFloat)size
{
    return [self iconWithCode:@"\uf109" size:size];
}

+ (instancetype)circleMinusIconWithSize:(CGFloat)size
{
    return [self iconWithCode:@"\uf10a" size:size];
}

+ (instancetype)albumIconWithSize:(CGFloat)size
{
    return [self iconWithCode:@"\uf10b" size:size];
}

+ (instancetype)editIconWithSize:(CGFloat)size
{
    return [self iconWithCode:@"\uf10c" size:size];
}

+ (instancetype)altHomeIconWithSize:(CGFloat)size
{
    return [self iconWithCode:@"\uf10d" size:size];
}

+ (instancetype)altUserIconWithSize:(CGFloat)size
{
    return [self iconWithCode:@"\uf10e" size:size];
}

+ (instancetype)compassIconWithSize:(CGFloat)size
{
    return [self iconWithCode:@"\uf10f" size:size];
}

//跟安卓版 的消息图片
+ (instancetype)pictureIconWithSize:(CGFloat)size
{
    return [self iconWithCode:@"\uf101" size:size];
}

+ (NSDictionary *)allIcons
{
    return @{
             @"\uf100" : @"chatBox",
             @"\uf101" : @"chatBubble",
             @"\uf102" : @"circleBack",
             @"\uf103" : @"circlePlus",
             @"\uf10a" : @"circleMinus",
             @"\uf104" : @"eye",
             @"\uf105" : @"gear",
             @"\uf106" : @"heart",
             @"\uf107" : @"home",
             @"\uf108" : @"user",
             @"\uf109" : @"camera",
             @"\uf10b" : @"album",
             @"\uf10c" : @"edit",
             @"\uf10d" : @"altHome",
             @"\uf10e" : @"altUser",
             @"\uf10f" : @"compass",
             @"\uf110" : @"picture",
             
             @"\uf259" : @"share",
             };
}

@end
