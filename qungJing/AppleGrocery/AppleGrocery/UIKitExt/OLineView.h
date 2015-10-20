//
//  OLineView.h
//  AppleGrocery
//
//  Created by Su on 3/29/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OLineView : UIView

@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor* lineColor;
@property (nonatomic, strong) UIColor* lineShadowColor;
@property (nonatomic, assign) CGFloat lineShadowOffsetY;

@end
