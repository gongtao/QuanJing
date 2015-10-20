//
//  OFullViewNavCon.m
//  Weitu
//
//  Created by Su on 5/20/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OFullViewNavCon.h"
#import <FLKAutoLayout/UIView+FLKAutoLayout.h>
#import <NSObject+AssociatedDictionary/NSObject+AssociatedDictionary.h>

@interface OFullViewNavCon ()
{
    NSMutableArray* _viewCons;
}

@end

@implementation OFullViewNavCon

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _pushPopDuration = 0.33;
        _viewCons = [NSMutableArray array];
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - ViewControllers push / pop

- (void)pushViewCon:(UIViewController*)viewCon animated:(BOOL)animated
{
    if ([_viewCons containsObject:viewCon])
    {
        // TODO assert false
        return;
    }
    
    UIViewController* lastViewCon = [_viewCons lastObject];
    
    [_viewCons addObject:viewCon];
    [self addChildViewController:viewCon];
    
    [self.view addSubview:viewCon.view];
    
    [viewCon.view constrainWidthToView:self.view predicate:nil];
    [viewCon.view constrainHeightToView:self.view predicate:nil];
    [viewCon.view alignCenterYWithView:self.view predicate:nil];
    
    NSLayoutConstraint* leadingConstraint = [viewCon.view alignLeadingEdgeWithView:self.view predicate:nil].firstObject;
    viewCon.properties[@"OKenBurnsNavCon.leadingConstraint"] = leadingConstraint;

    NSLayoutConstraint* lastLeadingConstraint = nil;
    if (lastViewCon != nil)
    {
        lastLeadingConstraint = lastViewCon.properties[@"OKenBurnsNavCon.leadingConstraint"];
        [lastViewCon viewWillDisappear:animated];
    }
    
    [viewCon viewWillAppear:animated];

    if (animated)
    {
        leadingConstraint.constant = self.view.bounds.size.width;
        [self.view layoutIfNeeded];
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             leadingConstraint.constant = 0.0;
                             if (lastLeadingConstraint != nil)
                             {
                                 lastLeadingConstraint.constant = -self.view.bounds.size.width;
                             }
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL isFinished) {

                             [viewCon viewDidAppear:YES];

                             if (lastViewCon != nil)
                             {
                                 lastViewCon.view.hidden = YES;
                                 [lastViewCon viewDidDisappear:YES];
                             }
                         }];
    }
    else
    {
        [viewCon viewDidAppear:NO];
        if (lastLeadingConstraint != nil)
        {
            lastLeadingConstraint.constant = -self.view.bounds.size.width;
            lastViewCon.view.hidden = YES;
            [lastViewCon viewDidDisappear:NO];
        }
        [self.view layoutIfNeeded];
    }
   
    self.navigationItem.title = viewCon.navigationItem.title;
}

- (void)popViewConAnimated:(BOOL)animated
{
    UIViewController* currentViewCon = [_viewCons lastObject];
    [_viewCons removeLastObject];
    
    NSLayoutConstraint* leadingConstraint = currentViewCon.properties[@"OKenBurnsNavCon.leadingConstraint"];
    
    UIViewController* lastViewCon = [_viewCons lastObject];
    NSLayoutConstraint* lastLeadingConstraint = nil;
    if (lastViewCon != nil)
    {
        lastLeadingConstraint = lastViewCon.properties[@"OKenBurnsNavCon.leadingConstraint"];
        lastViewCon.view.hidden = NO;
        [lastViewCon viewWillAppear:animated];
    }
    
    [currentViewCon viewWillDisappear:animated];

    if (animated)
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             leadingConstraint.constant = self.view.bounds.size.width;
                             if (lastLeadingConstraint != nil)
                             {
                                 lastLeadingConstraint.constant = 0;
                             }
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL isFinished) {
                             [currentViewCon.view removeFromSuperview];
                             [currentViewCon removeFromParentViewController];
                             if (lastViewCon != nil)
                             {
                                 [lastViewCon viewDidAppear:YES];
                             }
                             [currentViewCon viewDidDisappear:YES];
                         }];
    }
    else
    {
        if (leadingConstraint != nil)
        {
            lastLeadingConstraint.constant = 0;
        }

        [currentViewCon viewDidDisappear:NO];
        [lastViewCon viewDidAppear:NO];

        [currentViewCon.view removeFromSuperview];
        [currentViewCon removeFromParentViewController];

        [self.view layoutIfNeeded];
    }

    self.navigationItem.title = lastViewCon.navigationItem.title;
}

@end
