//
//  OQJTheme.h
//  Weitu
//
//  Created by Su on 8/24/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OQJTheme : NSObject

+ (OQJTheme*)sharedInstance;

@property (nonatomic, readonly) UIColor* themeColor;
@property (nonatomic, readonly, strong) UIImage* themeColorImage;
@property (nonatomic, readonly, strong) UIImage* grayThemeColorImage;

- (void)applyGlobalNavBarStyle;

@end
