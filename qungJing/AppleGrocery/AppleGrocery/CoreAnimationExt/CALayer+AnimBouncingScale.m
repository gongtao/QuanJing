//
//  CALayer+AnimBouncingScale.m
//  Lego
//
//  Created by Bing SU on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CALayer+AnimBouncingScale.h"

#define MAX_RATIO 1.05
#define MIN_RATIO 0.95

#define ANIMATION_DURATION 0.5
#define ANIMATION_REPEAT FLT_MAX

#define ANIMATION_KEY @"LegoBouncingScaleAnimation"

@implementation CALayer (AnimBouncingScale)

- (void)startBouncingScaleAnimation
{
    [self removeAnimationForKey:ANIMATION_KEY];

    float baseScale = [(NSNumber*)[self valueForKeyPath:@"transform.scale"] floatValue];

    CAMediaTimingFunction* timing = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    CABasicAnimation* headAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    headAnim.duration = ANIMATION_DURATION;
    headAnim.fromValue = [self.presentationLayer valueForKeyPath:@"transform.scale"];
    headAnim.toValue = [NSNumber numberWithFloat:baseScale * MIN_RATIO];
    headAnim.timingFunction = timing;

    CABasicAnimation* bodyAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    bodyAnim.duration = ANIMATION_DURATION;
    bodyAnim.repeatCount = ANIMATION_REPEAT;
    bodyAnim.autoreverses=YES;
    bodyAnim.fromValue = [NSNumber numberWithFloat:baseScale * MIN_RATIO];
    bodyAnim.toValue = [NSNumber numberWithFloat:baseScale * MAX_RATIO];
    bodyAnim.beginTime = ANIMATION_DURATION;

    //group the two animation
    CAAnimationGroup* group = [CAAnimationGroup animation];
    group.duration = FLT_MAX;
    [group setAnimations:[NSArray arrayWithObjects:headAnim, bodyAnim, nil]];

    //apply the grouped animaton
    [self addAnimation:group forKey:ANIMATION_KEY];
}

- (void)stopBouncingScaleAnimation
{
    [self removeAnimationForKey:ANIMATION_KEY];

    CAMediaTimingFunction* timing = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    CABasicAnimation* tailScaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    tailScaleAnimation.duration = ANIMATION_DURATION;
    tailScaleAnimation.fromValue = [self.presentationLayer valueForKeyPath:@"transform.scale"];
    tailScaleAnimation.toValue = [self valueForKeyPath:@"transform.scale"];
    tailScaleAnimation.timingFunction = timing;

    //group the two animation
    CAAnimationGroup* bodyGroup = [CAAnimationGroup animation];
    bodyGroup.duration = ANIMATION_DURATION;
    [bodyGroup setAnimations:[NSArray arrayWithObjects:tailScaleAnimation, nil]];
    [self addAnimation:bodyGroup forKey:ANIMATION_KEY];
}

@end
