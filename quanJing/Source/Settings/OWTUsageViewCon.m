//
//  OWTUsageViewCon.m
//  Weitu
//
//  Created by Su on 5/22/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUsageViewCon.h"
#import "UIViewController+WTExt.h"

@interface OWTUsageViewCon ()

@end

@implementation OWTUsageViewCon

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
    [self substituteNavigationBarBackItem];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor whiteColor];
}

@end
