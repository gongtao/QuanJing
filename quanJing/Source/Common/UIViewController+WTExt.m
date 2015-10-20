//
//  UIViewController+WTExt.m
//  Weitu
//
//  Created by Su on 4/25/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "UIViewController+WTExt.h"
#import "OWTFont.h"
#import "UIImage+Resize.h"
#import "RRConst.h"
@implementation UIViewController (WTExt)

- (void)substituteNavigationBarBackItem
{
    if ([self.navigationController.viewControllers objectAtIndex:0] != self)
    {
        if (self.navigationItem.leftBarButtonItem != nil &&
            self.navigationItem.leftBarButtonItem.tag == 0xbac0)
        {
            return;
        }
        
        UIBarButtonItem* barBackItem = [self createCircleBackBarButtonItemWithTarget:self
                                                                              action:@selector(popViewControllerWithAnimation)];
        self.navigationItem.hidesBackButton = TRUE;
        [self.navigationItem setLeftBarButtonItem:barBackItem animated:NO];
        self.navigationItem.leftBarButtonItem.tag = 0xbac0;
    }
    else
    {
        if (self.navigationItem.leftBarButtonItem != nil &&
            self.navigationItem.leftBarButtonItem.tag == 0xbac0)
        {
            self.navigationItem.leftBarButtonItem = nil;
        }
    }
}

- (void)substituteNavigationBarBackItem2
{
    
    UIBarButtonItem* barBackItem = [self createCircleBackBarButtonItemWithTarget:self
                                                                          action:@selector(popViewControllerWithAnimation)];
    self.navigationItem.hidesBackButton = TRUE;
    [self.navigationItem setLeftBarButtonItem:barBackItem animated:NO];
    self.navigationItem.leftBarButtonItem.tag = 0xbac0;
}

- (UIBarButtonItem*)createCircleBackBarButtonItemWithTarget:(id)target action:(SEL)action
{
    static UIImage* kBackImage = nil;
    if (kBackImage == nil)
    {
        kBackImage = [[OWTFont circleBackIconWithSize:32] imageWithSize:CGSizeMake(26, 26)];
        kBackImage = [kBackImage croppedImage:CGRectMake(0, 4, 52, 48)];
        kBackImage = [kBackImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
    [backButton setImage:kBackImage forState:UIControlStateNormal];
    [backButton setShowsTouchWhenHighlighted:TRUE];
    [backButton addTarget:target action:action forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem* barBackItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    return barBackItem;
}

- (void)popViewControllerWithAnimation
{
    if (self.view.tag == 8173) {
        [self revidePopViewController];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)revidePopViewController
{
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    UIApplication *application = [UIApplication sharedApplication];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    //self.navigationController.navigationBar.barTintColor = GetThemer().homePageColor;
    [self.navigationController popViewControllerAnimated:YES];
}
@end
