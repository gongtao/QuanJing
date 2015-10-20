//
//  OWTCaptureViewCon.h
//  Weitu
//
//  Created by Su on 5/30/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWTCaptureSourceSelectViewCon : UIViewController

@property (nonatomic, strong) UIImage* enterViewShotImage;
@property (nonatomic, strong) UIImage* exitViewShotImage;

@property (nonatomic, strong) void (^exitToLastViewConAction)();

- (void)performExitAnimationWithDoneAction:(void (^)())doneAction;
- (void)exitToLastViewCon;

@end
