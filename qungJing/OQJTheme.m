//
//  OQJTheme.m
//  Weitu
//
//  Created by Su on 8/24/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OQJTheme.h"
#import "UIImage+ColorExt.h"
#import "OWTAssetViewCon.h"
#import <UIColor-HexString/UIColor+HexString.h>

static OQJTheme* s_sharedInstance;

@interface OQJTheme()
{
}

@end

@implementation OQJTheme

+ (OQJTheme*)sharedInstance
{
    if (s_sharedInstance == nil)
    {
        s_sharedInstance = [[OQJTheme alloc] init];
        [s_sharedInstance applyGlobalAppearance];
    }
    
    return s_sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _themeColor = [UIColor colorWithHexString:@"0090ff"];
        _themeColorImage = [UIImage imageWithColor:_themeColor];
        _grayThemeColorImage = [UIImage imageWithColor:[UIColor colorWithWhite:0.9 alpha:1.0]];
    }
    return self;
}

- (void)applyGlobalAppearance
{
    UIImage* blackImage = [UIImage imageWithColor:[UIColor blackColor]];
    [[UITabBar appearance] setBackgroundImage:blackImage];
    [self applyGlobalNavBarStyle];
}

- (void)applyGlobalNavBarStyle
{
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackOpaque];
    [[UINavigationBar appearance] setBarTintColor:[OQJTheme sharedInstance].themeColor];//bar颜色
    
//    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];//title
    [[UINavigationBar appearance] setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
    
    NSDictionary* normalAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
    [[UIBarButtonItem appearance] setTitleTextAttributes:normalAttributes forState: UIControlStateNormal];
    
    NSDictionary* disabledAttributes = @{ NSForegroundColorAttributeName: [UIColor colorWithWhite:0.8 alpha:1.0] };
    [[UIBarButtonItem appearance] setTitleTextAttributes:disabledAttributes forState: UIControlStateDisabled];
}

@end
