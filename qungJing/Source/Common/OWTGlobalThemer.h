//
//  OWTGlobalThemer.h
//  Weitu
//
//  Created by Su on 3/29/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWTGlobalThemer : NSObject

@property (nonatomic, strong) UIColor* themeColor;
@property (nonatomic, strong) UIColor* themeHighlightColor;
@property (nonatomic, strong) UIColor* themeTintColor;
@property (nonatomic, strong) UIColor* themeColorRed;
@property (nonatomic, strong) UIColor* themeColorBackground;
@property (nonatomic, strong) UIColor* homePageColor;
@property (nonatomic, strong) UIFont* normalFont;
@property (nonatomic, strong) UIFont* bigTitleFont;
@property (nonatomic, strong) UIFont* bigTextFont;
@property (nonatomic, strong) UIFont* barButtonTextFont;

@property (nonatomic, strong) UIFont* labelFont;
@property (nonatomic, strong) UIFont* buttonFont;
@property (nonatomic, strong) UIFont* systemFont;
@property (nonatomic, strong) UIFont* smallSystemFont;

@property (nonatomic, assign) BOOL ifCommentPop;
- (void)apply;

@end
