//
//  OKenBurnsNavCon.h
//  Weitu
//
//  Created by Su on 5/20/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JBKenBurnsView/JBKenBurnsView.h>

@interface OKenBurnsNavCon : UIViewController<JBKenBurnsViewDelegate>

@property (nonatomic, copy) NSArray* backgroundImages;
@property (nonatomic, assign) float transitionDuration;
@property (nonatomic, assign) float initialDelay;

- (id)initWithBackgroundImages:(NSArray*)backgroundImages
            transitionDuration:(float)transitionDuration
                  initialDelay:(float)initialDelay;

@end
