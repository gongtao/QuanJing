//
//  OScaleButton.m
//  TaxiRadar
//
//  Created by Su on 4/30/12.
//
//

#import "OScaleButton.h"

@implementation OScaleButton

- (id)init
{
    self = [super init];
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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self construct];
    }
    return self;
}

- (void)construct
{
    [self addTarget:self action:@selector(onTouchDown) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(onTouchUp) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(onTouchUp) forControlEvents:UIControlEventTouchUpOutside];
}

- (void)onTouchDown
{
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.transform = CGAffineTransformMakeScale(2.5, 2.5);
                     }
                     completion:nil
     ];
}

- (void)onTouchUp
{
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     }
                     completion:nil
     ];
}

@end
