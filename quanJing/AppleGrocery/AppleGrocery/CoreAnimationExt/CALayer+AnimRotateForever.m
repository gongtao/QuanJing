//
//  CALayer+AnimRotateForever.m
//  Lego
//
//  Created by Bing SU on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CALayer+AnimRotateForever.h"

#define ANIMATION_KEY @"LegoBouncingScaleAnimation"
static const float kAngularVelocity = M_PI * 3.0;

@implementation CALayer (AnimRotateForever)

- (void)startRotateForeverAnimation
{
    [self removeAnimationForKey:ANIMATION_KEY];

    float startAngle = ((NSNumber*)[self.presentationLayer valueForKeyPath:@"transform.rotation.z"]).floatValue;
    float endAngle;
    if (startAngle < 0.0)
    {
        endAngle = M_PI; 
    }
    else
    {
        endAngle = M_PI * 2.0;
    }

    float angleDiff = endAngle - startAngle;
    
    float headDuration = angleDiff / kAngularVelocity;

    NSMutableArray* headValues = [NSMutableArray array];
    [headValues addObject:[NSNumber numberWithFloat:startAngle]];
    [headValues addObject:[NSNumber numberWithFloat:startAngle + angleDiff * 0.25]];
    [headValues addObject:[NSNumber numberWithFloat:startAngle + angleDiff * 0.5]];
    [headValues addObject:[NSNumber numberWithFloat:startAngle + angleDiff * 0.75]];
    [headValues addObject:[NSNumber numberWithFloat:startAngle + angleDiff]];

    CAKeyframeAnimation* animHead = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    animHead.values = headValues;
    animHead.duration = headDuration;
    animHead.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];

    NSMutableArray* bodyValues = [NSMutableArray array];
    [bodyValues addObject:[NSNumber numberWithFloat:M_PI * 0.0]];
    [bodyValues addObject:[NSNumber numberWithFloat:M_PI * 0.5]];
    [bodyValues addObject:[NSNumber numberWithFloat:M_PI * 1.0]];
    [bodyValues addObject:[NSNumber numberWithFloat:M_PI * 1.5]];
    [bodyValues addObject:[NSNumber numberWithFloat:M_PI * 2.0]];

    CAKeyframeAnimation* animBody = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    animBody.values = bodyValues;
    animBody.duration = M_PI * 2.0 / kAngularVelocity;
    animBody.beginTime = headDuration;
    animBody.repeatCount = FLT_MAX;
    animBody.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

    CAAnimationGroup* animGroup = [CAAnimationGroup animation];
    animGroup.duration = FLT_MAX;
    [animGroup setAnimations:[NSArray arrayWithObjects:animHead, animBody, nil]];
    [self addAnimation:animGroup forKey:ANIMATION_KEY];

    return;
}

- (void)stopRotateForeverAnimation
{
    [self removeAnimationForKey:ANIMATION_KEY];

    float startAngle = ((NSNumber*)[self.presentationLayer valueForKeyPath:@"transform.rotation.z"]).floatValue;
    float endAngle;
    if (startAngle < 0.0)
    {
        endAngle = 0.0;
    }
    else
    {
        endAngle = M_PI * 2.0;
    }

    float angleDiff = endAngle - startAngle;

    float tailDuration = angleDiff / kAngularVelocity;

    NSMutableArray* headValues = [NSMutableArray array];
    [headValues addObject:[NSNumber numberWithFloat:startAngle]];
    [headValues addObject:[NSNumber numberWithFloat:startAngle + angleDiff * 0.25]];
    [headValues addObject:[NSNumber numberWithFloat:startAngle + angleDiff * 0.5]];
    [headValues addObject:[NSNumber numberWithFloat:startAngle + angleDiff * 0.75]];
    [headValues addObject:[NSNumber numberWithFloat:startAngle + angleDiff]];

    CAKeyframeAnimation* animTail = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    animTail.values = headValues;
    animTail.duration = tailDuration;
    animTail.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self addAnimation:animTail forKey:ANIMATION_KEY];

    return;
}

@end
