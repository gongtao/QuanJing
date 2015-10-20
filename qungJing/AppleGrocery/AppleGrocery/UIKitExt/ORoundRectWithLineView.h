//
//  ORoundRectWithLineView.h
//  Weitu
//
//  Created by Su on 3/29/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "ORoundRectView.h"

@interface ORoundRectWithLineView : ORoundRectView

@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor* lineColor;
@property (nonatomic, strong) UIColor* lineShadowColor;
@property (nonatomic, assign) CGFloat lineShadowOffsetY;
@property (nonatomic, assign) NSInteger segmentNum;

@end
