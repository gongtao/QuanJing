//
//  OShadowView.m
//  TaxiRadar
//
//  Created by Su on 04/11/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OShadowView.h"
#import "UIView+UIExt.h"
#import <QuartzCore/QuartzCore.h>

@implementation OShadowView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self construct];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self construct];
    }
    return self;
}

-(void)construct
{
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
//    self.layer.shadowOffset = CGSizeMake(0.0f, -.0f);
    self.layer.shadowRadius = 3.0f;
    self.layer.shadowOpacity = 1.0f;
    _isFitting = false;
}

- (void)addSubview:(UIView *)view
{
    [super addSubview:view];

    [view addObserver:self forKeyPath:@"layer.bounds" options:NSKeyValueObservingOptionOld context:NULL];
    [view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionOld context:NULL];
    [view addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionOld context:NULL];

    [self fit];
}

- (void)willRemoveSubview:(UIView *)subview
{
    [subview removeObserver:self forKeyPath:@"layer.bounds" context:NULL];
    [subview removeObserver:self forKeyPath:@"frame" context:NULL];
    [subview removeObserver:self forKeyPath:@"bounds" context:NULL];

    [self fit];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void *)context
{
//    if ([keyPath isEqualToString:@"layer.bounds"])
    {
        [self fit];
    }
}

- (void)fit
{
    if (_isFitting)
    {
        return;
    }

    _isFitting = true;

    CGSize newSize = [self calcSizeToFitSubviews];
    CGSize oldSize = self.bounds.size;

    if (CGSizeEqualToSize(newSize, oldSize))
    {
        _isFitting = false;
        return;
    }

    CGRect frame = self.frame;
    frame.size = newSize;
    self.frame = frame;

    CGRect bounds;
    bounds = CGRectMake(0, 0, oldSize.width, oldSize.height);
    CGPathRef startPath = CGPathCreateWithRect(bounds, nil);

    bounds.size = newSize;
    CGPathRef endPath = CGPathCreateWithRect(bounds, nil);

    self.layer.shadowPath = endPath;
    CABasicAnimation* animShadow = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
    animShadow.fromValue = (__bridge_transfer id)startPath;
    animShadow.toValue = (__bridge_transfer id)endPath;
    animShadow.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animShadow.duration = 0.3;
    [self.layer addAnimation:animShadow forKey:nil];

    _isFitting = false;
}

@end
