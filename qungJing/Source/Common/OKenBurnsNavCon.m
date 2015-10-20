//
//  OKenBurnsNavCon.m
//  Weitu
//
//  Created by Su on 5/20/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OKenBurnsNavCon.h"

@interface OKenBurnsNavCon ()
{
    JBKenBurnsView* _kenBurnsView;
}

@end

@implementation OKenBurnsNavCon

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (id)initWithBackgroundImages:(NSArray*)backgroundImages
            transitionDuration:(float)transitionDuration
                  initialDelay:(float)initialDelay
{
    self = [self initWithNibName:nil bundle:nil];
    if (self != nil)
    {
        _backgroundImages = backgroundImages;
        _transitionDuration = transitionDuration;
        _initialDelay = initialDelay;
    }
    return self;
}

- (void)setup
{
    _backgroundImages = nil;
    _transitionDuration = 20.0;
    _initialDelay = 0.3;
}

- (void)loadView
{
    _kenBurnsView = [[JBKenBurnsView alloc] initWithFrame:CGRectZero];
    _kenBurnsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = _kenBurnsView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startBackgroundAnimationWithDelay:_initialDelay];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_kenBurnsView stopAnimation];
    [super viewWillDisappear:animated];
}

#pragma mark - Background Related

- (void)startBackgroundAnimation
{
    [self startBackgroundAnimationWithDelay:0];
}

- (void)startBackgroundAnimationWithDelay:(float)delay
{
    if (_backgroundImages == nil)
    {
        return;
    }

    if (_kenBurnsView.isAnimating)
    {
        return;
    }

    [_kenBurnsView animateWithImages:_backgroundImages
                  transitionDuration:_transitionDuration
                        initialDelay:delay
                                loop:YES
                         isLandscape:YES];
}

- (void)stopBackgroundAnimation
{
    [_kenBurnsView stopAnimation];
}

#pragma mark - Accessors

- (void)setBackgroundImages:(NSArray *)backgroundImages
{
    _backgroundImages = backgroundImages;
    if (_kenBurnsView.isAnimating)
    {
        [self stopBackgroundAnimation];
        [self startBackgroundAnimation];
    }
}

- (void)setTransitionDuration:(float)transitionDuration
{
    _transitionDuration = transitionDuration;
    if (_kenBurnsView.isAnimating)
    {
        [self stopBackgroundAnimation];
        [self startBackgroundAnimation];
    }
}

@end
