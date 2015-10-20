#import "UIView+AnimExt.h"

@implementation UIView (KeyframeAnimExt)

- (void)animateLayerWithKeyPath:(NSString *)path
                      fromValue:(CGFloat)fromValue
                        toValue:(CGFloat)toValue
                       duration:(NSTimeInterval)duration
                       function:(AHEasingFunction)function
{
    CALayer* layer = self.layer;
    
    CAAnimation* anim = [CAKeyframeAnimation animationWithKeyPath:path
                                                         function:function
                                                        fromValue:fromValue
                                                          toValue:toValue];
    anim.duration = duration;
    [layer addAnimation:anim forKey:nil];
    [layer setValue:[NSNumber numberWithFloat:toValue] forKeyPath:path];
}

- (void)animateLayerWithKeyPath:(NSString *)path
                        toValue:(CGFloat)toValue
                       duration:(NSTimeInterval)duration
                       function:(AHEasingFunction)function
{
    float fromValue = [[self.layer.presentationLayer valueForKeyPath:path] floatValue];
    [self animateLayerWithKeyPath:path fromValue:fromValue toValue:toValue duration:duration function:function];
}

@end

