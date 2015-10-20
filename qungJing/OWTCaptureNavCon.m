//
//  OWTCaptureNavCon.m
//  Weitu
//
//  Created by Su on 6/1/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTCaptureNavCon.h"
#import "OWTFont.h"
#import "OWTCaptureSourceSelectViewCon.h"

@interface OWTCaptureNavCon ()
{
    OWTCaptureSourceSelectViewCon* _sourceSelectionViewCon;
}

@end

@implementation OWTCaptureNavCon

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    [self setupTabBarItem];
    _sourceSelectionViewCon = [[OWTCaptureSourceSelectViewCon alloc] initWithNibName:nil bundle:nil];
    [self pushViewController:_sourceSelectionViewCon animated:NO];
}

- (void)setupTabBarItem
{
    UIImage* cameraImage = [[OWTFont cameraIconWithSize:32] imageWithSize:CGSizeMake(32, 32)];
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"拍照" image:cameraImage selectedImage:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)performExitAnimationWithDoneAction:(void (^)())doneAction
{
    if (self.topViewController == _sourceSelectionViewCon)
    {
        [_sourceSelectionViewCon performExitAnimationWithDoneAction:doneAction];
    }
}

- (void)exitToLastViewCon
{
    if (self.topViewController == _sourceSelectionViewCon)
    {
        [_sourceSelectionViewCon exitToLastViewCon];
    }
}

- (void)setEnterViewShotImage:(UIImage *)enterViewShotImage
{
    [_sourceSelectionViewCon setEnterViewShotImage:enterViewShotImage];
}

- (void)setExitViewShotImage:(UIImage *)exitViewShotImage
{
    [_sourceSelectionViewCon setExitViewShotImage:exitViewShotImage];
}

- (void)setExitToLastViewConAction:(void (^)())exitToLastViewConAction
{
    [_sourceSelectionViewCon setExitToLastViewConAction:exitToLastViewConAction];
}

@end
