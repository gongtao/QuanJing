//
//  ORoundRectLineView.h
//  AppleGrocery
//
//  Created by Su on 6/10/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ORoundRectLineView : UIView

@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat marginX;
@property (nonatomic, assign) CGFloat marginY;
@property (nonatomic, strong) UIColor* strokeColor;
@property (nonatomic, assign) CGFloat lineWidth;

@end
