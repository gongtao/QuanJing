#pragma once

#import "../CoreAnimationExt/CAKeyframeAnimation+AHEasing/CAKeyframeAnimation+AHEasing.h"

@interface UIView (KeyframeAnimExt)

- (void)animateLayerWithKeyPath:(NSString *)path
                      fromValue:(CGFloat)fromValue
                        toValue:(CGFloat)toValue
                       duration:(NSTimeInterval)duration
                       function:(AHEasingFunction)function;

- (void)animateLayerWithKeyPath:(NSString *)path
                        toValue:(CGFloat)toValue
                       duration:(NSTimeInterval)duration
                       function:(AHEasingFunction)function;
@end
