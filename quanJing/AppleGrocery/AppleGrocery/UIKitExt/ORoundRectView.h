//
//  ORoundCornerView.h
//  Weitu
//
//  Created by Su on 3/29/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ORoundRectView : UIView

@property (nonatomic, strong) UIColor* fillColor;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat marginX;
@property (nonatomic, assign) CGFloat marginY;
@property (nonatomic, assign) CGSize shadowOffset;
@property (nonatomic, assign) CGFloat shadowBlurRadius;
@property (nonatomic, strong) UIColor* shadowColor;

- (void)setup;

@end
