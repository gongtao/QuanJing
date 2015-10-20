//
//  OFullViewNavCon.h
//  Weitu
//
//  Created by Su on 5/20/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OFullViewNavCon : UIViewController

@property (nonatomic, assign) float pushPopDuration;

- (void)pushViewCon:(UIViewController*)viewCon animated:(BOOL)animated;
- (void)popViewConAnimated:(BOOL)animated;

@end
