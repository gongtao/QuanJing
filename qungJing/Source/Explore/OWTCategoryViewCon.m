//
//  OWTCategoryViewCon.m
//  Weitu
//
//  Created by Su on 5/12/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTCategoryViewCon.h"
#import "UIViewController+WTExt.h"
#import "OWTFeedViewCon.h"
#import "UIView+EasyAutoLayout.h"
#import "OWTFeedManager.h"
#import "OWTCategoryManager.h"
#import "SVProgressHUD+WTError.h"
#import "OWTAuthManager.h"
#import <SIAlertView/SIAlertView.h>
#import <UISearchBar-Blocks/UISearchBar+Blocks.h>
#import "OWTAssetManager.h"
#import "OWTSearchManager.h"
#import "OWTSearchResultsViewCon.h"
#import "FeedViewCon.h"
#import "RRConst.h"
#import "OWTTabBarHider.h"
@interface OWTCategoryViewCon ()
{
}

@property (nonatomic, strong) UISearchBar* searchBar;
@property (nonatomic, strong) OWTCategory* category;
@property (nonatomic, strong) FeedViewCon* feedViewCon;

@end

@implementation OWTCategoryViewCon
{
    OWTTabBarHider *_tabBarHider;
}
- (id)initWithCategory:(OWTCategory*)category
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _category = category;
        [self setup];
        _tabBarHider=[[OWTTabBarHider alloc]init];
    }
    return self;
}

- (void)setup
{
#if 0
    [self setupNavigationBar];
#endif
    [self setupSearchBar];
    _feedViewCon = [[FeedViewCon alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:_feedViewCon];}

- (void)setupNavigationBar
{
    self.navigationItem.title = _category.categoryName;
//    
//    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 100, 44)];
//    label.text = [NSString stringWithFormat:@"%@",_category.categoryName];
//    
//    label.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:24];
//    
//    [label setTextAlignment:NSTextAlignmentCenter];
//    label.textColor = GetThemer().themeTintColor;
//    self.navigationItem.titleView =label;
   // UIBarButtonItem* subscribeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
//                                                                            style:UIBarButtonItemStyleDone
//                                                                           target:self
//                                                                           action:@selector(subscribeButtonPressed)];
    //self.navigationItem.rightBarButtonItem = subscribeButtonItem;

    //[self updateSubscriptionButtonTitle];
}

- (void)updateSubscriptionButtonTitle
{
    BOOL isSubscribed = [GetCategoryManager() isCategorySubscribedByCurrentUser:_category];
    if (isSubscribed)
    {
        self.navigationItem.rightBarButtonItem.title = @"- 取消订阅";
    }
    else
    {
        self.navigationItem.rightBarButtonItem.title = @"+ 订阅";
    }
}

- (void)setupSearchBar
{
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 260, 44)];
    [_searchBar setPlaceholder:@"搜索"];
    _searchBar.delegate = self;
    _searchBar.translucent = NO;
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    [_searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"SearchBarBG"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)]
                                     forState:UIControlStateNormal];
    _searchBar.searchTextPositionAdjustment = UIOffsetMake(4, 1);
    _searchBar.searchFieldBackgroundPositionAdjustment = UIOffsetMake(0, 0);
    [_searchBar setPositionAdjustment:UIOffsetMake(0, 1) forSearchBarIcon:UISearchBarIconSearch];
    
    [self setupSearchBarActions];
    //_searchBar.backgroundColor = [UIColor redColor];
    self.navigationItem.titleView = _searchBar;
}

- (void)setupSearchBarActions
{
    __weak OWTCategoryViewCon* wself = self;
    
    [_searchBar setSearchBarCancelButtonClickedBlock:^(UISearchBar* searchBar){
        [wself.searchBar resignFirstResponder];
    }];
    
    [_searchBar setSearchBarSearchButtonClickedBlock:^(UISearchBar* searchBar) {
        [wself performSearch];
    }];
    
    [_searchBar setSearchBarShouldBeginEditingBlock:^BOOL(UISearchBar* searchBar) {
        [searchBar setShowsCancelButton:YES animated:YES];
        return YES;
    }];
    
    [_searchBar setSearchBarShouldEndEditingBlock:^BOOL(UISearchBar* searchBar) {
        [searchBar setShowsCancelButton:NO animated:YES];
        return YES;
    }];
}




- (void)subscribeButtonPressed
{
    OWTAuthManager* am = GetAuthManager();
    if (!am.isAuthenticated)
    {
        SIAlertView* alertView = [[SIAlertView alloc] initWithTitle:@"请登录" andMessage:@"订阅功能需要登录后使用"];
        [alertView addButtonWithTitle:@"登录"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView* alertView) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [am showAuthViewConWithSuccess:^{ [self updateSubscriptionButtonTitle]; }
                                                              cancel:nil];
                                  });
                                  [alertView dismissAnimated:YES];
                              }];
        
        [alertView addButtonWithTitle:@"取消"
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView* alertView) {
                                  [alertView dismissAnimated:YES];
                              }];
        
        alertView.transitionStyle = SIAlertViewTransitionStyleFade;
        [alertView show];
    }
    else
    {
        BOOL isSubscribed = [GetCategoryManager() isCategorySubscribedByCurrentUser:_category];
        [GetCategoryManager() modifyCategory:_category
                                subscription:!isSubscribed
                                     success:^{
                                         [SVProgressHUD dismiss];
                                         [self updateSubscriptionButtonTitle];
                                     }
                                     failure:^(NSError* error) {
                                         [SVProgressHUD showError:error];
                                     }];
    }
}



- (void)dealloc
{
    _searchBar.delegate = nil;
}

- (void)loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = GetThemer().themeColorBackground;
    [self.view addSubview:_feedViewCon.view];
//    [_feedViewCon.view easyFillSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [_tabBarHider hideTabBar];
    [self substituteNavigationBarBackItem];
}

//重写拓展类的方法
- (void)popViewControllerWithAnimation
{
    if(_ifNeedSetbackground){
//        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
//        UIApplication *application = [UIApplication sharedApplication];
//        [application setStatusBarStyle:UIStatusBarStyleLightContent];
//        self.navigationController.navigationBar.barTintColor = GetThemer().homePageColor;
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(BOOL) navigationShouldPopOnBackButton
{
    [self.navigationController popViewControllerAnimated:YES];
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (_feedViewCon.feed == nil)
    {
        OWTFeed* feed = [GetFeedManager() feedForCategory:_category];
        [_feedViewCon presentFeed:feed animated:animated refresh:YES];
    }
}

#pragma mark - Searching

- (void)performSearch
{
    NSString* keyword = _searchBar.text;
    
    [SVProgressHUD showWithStatus:@"搜索中..." maskType:SVProgressHUDMaskTypeBlack];
    
    OWTSearchManager* sm = GetSearchManager();
    [sm searchAssetsWithKeyword:keyword
                        success:^(NSArray* assets) {
                            [_searchBar resignFirstResponder];
                            
                            [SVProgressHUD dismiss];
                            
                            OWTSearchResultsViewCon* searchResultsViewCon = [[OWTSearchResultsViewCon alloc] initWithNibName:nil bundle:nil];
                            [searchResultsViewCon setKeyword:keyword withAssets:assets];
                            [self.navigationController pushViewController:searchResultsViewCon animated:YES];
                        }
                        failure:^(NSError* error) {
                            [SVProgressHUD showError:error];
                        }];
}

@end
