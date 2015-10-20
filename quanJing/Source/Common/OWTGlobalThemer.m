//
//  OWTGlobalThemer.m
//  Weitu
//
//  Created by Su on 3/29/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTGlobalThemer.h"
#import "OWTFont.h"
#import <UIColor-HexString/UIColor+HexString.h>

@interface OWTGlobalThemer()
{
}

@end

@implementation OWTGlobalThemer

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _themeColor = [UIColor colorWithHexString:@"#3399cc"];
        _themeHighlightColor = [UIColor colorWithHexString:@"#297aa3"];
        _themeTintColor =  [UIColor whiteColor];
//        [UIColor colorWithHexString:@"#33bbff"];
        //_themeTintColor = [UIColor whiteColor];

        _themeColorRed = [UIColor colorWithHexString:@"#cc334d"];
        _themeColorBackground = [UIColor colorWithWhite:0.95 alpha:1.0];
    }
    return self;
}

- (void)apply
{
    _bigTitleFont = [UIFont systemFontOfSize:20.0];
    _bigTextFont = [UIFont systemFontOfSize:16.0];
    _barButtonTextFont = [UIFont systemFontOfSize:16.0];
    
    _labelFont = [UIFont systemFontOfSize:14];
    _buttonFont = [UIFont systemFontOfSize:[UIFont buttonFontSize]];
    _smallSystemFont = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    _systemFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    [self applyNavigationBarTheme];
    [self applyUITextFieldTheme];
    [self applyLableStyle];
    [self applySVProgressHUDStyle];
}

- (void)applyNavigationBarTheme
{
    //    [[UINavigationBar appearance] setTintColor:_themeTintColor];
    //    [[UIBarButtonItem appearance] setTintColor:_themeTintColor];
}

- (void)applyUITextFieldTheme
{
}

- (void)applyLableStyle
{
}

- (void)applySVProgressHUDStyle
{
    [[SVProgressHUD appearance] setHudFont:_bigTextFont];
}

@end
