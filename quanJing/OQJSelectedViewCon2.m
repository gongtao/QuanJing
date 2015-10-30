//
//  OQJSelectedViewCon.m
//  Weitu
//
//  Created by Su on 8/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OQJSelectedViewCon2.h"
//#import "OWTFeedViewCon.h"
//#import "OWTFeedManager.h"
//#import "OWTSearchViewCon.h"
#import <UIColor-HexString/UIColor+HexString.h>
#import <QBFlatButton/QBFlatButton.h>
#import <FontAwesomeKit/FontAwesomeKit.h>
#import <AppleGrocery/UIKitExt/OLineView.h>


#import "OWTFollowingUsersViewCon.h"
#import "OWTFollowerUsersViewCon.h"

#import "OWTUser.h"
#import "OWTUserManager.h"

#import "UIView+EasyAutoLayout.h"
#import "UIViewController+WTExt.h"
#import "OWTTabBarHider.h"
typedef enum
{
    kQJSelectedWorkingModeLatest,
    kQJSelectedWorkingModeHottest,
} EQJSelectedImageWorkingMode;

@interface OQJSelectedViewCon2 ()
{
    IBOutlet UIView* _buttonsView;
    IBOutlet QBFlatButton* _latestButton;
    IBOutlet QBFlatButton* _hottestButton;
    IBOutlet OLineView* _lineView;

    IBOutlet UIScrollView* _scrollView;

    int _currentPageIndex;
    NSArray* _pageButtons;
    NSArray* _pageViews;
    NSArray* _pageViewCons;
    OWTTabBarHider *_tabBatHider;
}

@end

@implementation OQJSelectedViewCon2

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tabBatHider=[[OWTTabBarHider alloc]init];
    _currentPageIndex = -1;
    [self setupNavBar];
    [self setupButtons];
    [self setupContentView];
}

- (void)setupNavBar
{
    self.title = @"圈子";
    [self substituteNavigationBarBackItem];
    
}

- (void)setupButtons
{
    _buttonsView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    _lineView.lineColor = [UIColor lightGrayColor];
    _lineView.lineWidth = 0.5;
    _lineView.lineShadowColor = nil;
    
    _pageButtons = @[ _latestButton, _hottestButton ];
    for (QBFlatButton* button in _pageButtons)
    {
        button.cornerRadius = 1;
        button.borderWidth = 0.5;
        button.height = 0;
        button.depth = 0;
        button.borderColor = [UIColor lightGrayColor];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:15];

        [button setSurfaceColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];

        [button setSurfaceColor:GetThemer().themeColor forState:UIControlStateSelected];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];

        [button setSurfaceColor:GetThemer().themeColor forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    }
}

- (void)setupContentView
{
    
    
    OWTFollowingUsersViewCon* latestViewCon = [[OWTFollowingUsersViewCon alloc] initWithNibName:nil bundle:nil];

    OWTFollowerUsersViewCon* hottestViewCon = [[OWTFollowerUsersViewCon alloc] initWithNibName:nil bundle:nil];
    _pageViews = @[ latestViewCon.view, hottestViewCon.view ];
    _pageViewCons = @[ latestViewCon, hottestViewCon ];
    
    for (UIView* view in _pageViews)
    {
        [_scrollView addSubview:view];
    }
    
    for (UIViewController* viewCon in _pageViewCons)
    {
        [self addChildViewController:viewCon];
    }

    _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width * _pageViews.count, _scrollView.bounds.size.height);
    [self layoutPageViews];

    [self presentPageAtIndex:0 animated:NO];
}

- (void)viewDidLayoutSubviews
{
    [self layoutPageViews];
}

- (void)search
{
//    OWTSearchViewCon* searchViewCon = [[OWTSearchViewCon alloc] initWithNibName:nil bundle:nil];
//    [self.navigationController pushViewController:searchViewCon animated:YES];
}

- (void)layoutPageViews
{
    float x = 0;
    float w = _scrollView.bounds.size.width;
    float h = _scrollView.bounds.size.height;
    for (UIView* view in _pageViews)
    {
        view.frame = CGRectMake(x, 0, w, h);
        x += w;
    }
}

- (IBAction)onLatestButtonPressed:(id)sender
{
    [self presentPageAtIndex:0 animated:YES];
}

- (IBAction)onHottestButtonPressed:(id)sender
{
    [self presentPageAtIndex:1 animated:YES];
}

- (void)presentPageAtIndex:(int)pageIndex animated:(BOOL)animated
{
    if (pageIndex == _currentPageIndex)
    {
        return;
    }
    
    if (_currentPageIndex >= 0 && _currentPageIndex < _pageButtons.count)
    {
        QBFlatButton* oldButton = _pageButtons[_currentPageIndex];
        oldButton.selected = NO;
        oldButton.borderWidth = 0.5;
    }

    _currentPageIndex = pageIndex;

    QBFlatButton* newButton = _pageButtons[_currentPageIndex];
    newButton.selected = YES;
    newButton.borderWidth = 0;

    float x = _scrollView.bounds.size.width * (CGFloat)pageIndex;
    [_scrollView setContentOffset:CGPointMake(x, 0) animated:animated];
    
//    OWTFeedViewCon* feedViewCon = _pageViewCons[_currentPageIndex];
//    [feedViewCon manualRefreshIfNeeded];
}
-(void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden=YES;
}

@end
