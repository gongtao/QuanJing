//
//  OWTSearchViewCon.m
//  Weitu
//
//  Created by Su on 4/25/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTSearchViewCon.h"
#import "UIViewController+WTExt.h"
#import "OWTServerError.h"

#import "SVProgressHUD+WTError.h"
#import "OWTAssetManager.h"
#import "UIView+EasyAutoLayout.h"
#import "OWTSearchManager.h"

#import <UISearchBar-Blocks/UISearchBar+Blocks.h>
#import <UIColor-HexString/UIColor+HexString.h>

#import "OWTSearchResultsViewCon.h"
#import "QuanJingSDK.h"
@interface OWTSearchViewCon ()
{
    OWTSearchResultsViewCon* _searchResultsViewCon;
}

@property (nonatomic, strong) UISearchBar* searchBar;

@end

@implementation OWTSearchViewCon

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupSearchBar];
    [self setupSearchResultsViewCon];
    [self substituteNavigationBarBackItem];
}

- (void)setupSearchBar
{
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 260, 44)];
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    [_searchBar setPlaceholder:@"搜索"];
    _searchBar.delegate = self;
    _searchBar.translucent = NO;
    [_searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"SearchBarBG"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)]
                                     forState:UIControlStateNormal];
    _searchBar.searchTextPositionAdjustment = UIOffsetMake(4, 1);
    _searchBar.searchFieldBackgroundPositionAdjustment = UIOffsetMake(0, 0);
    [_searchBar setPositionAdjustment:UIOffsetMake(0, 1) forSearchBarIcon:UISearchBarIconSearch];

    [self setupSearchBarActions];
    
    self.navigationItem.titleView = _searchBar;
}

- (void)setupSearchBarActions
{
    __weak OWTSearchViewCon* wself = self;

    [_searchBar setSearchBarCancelButtonClickedBlock:^(UISearchBar* searchBar) {
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

- (void)setupSearchResultsViewCon
{
    _searchResultsViewCon = [[OWTSearchResultsViewCon alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:_searchResultsViewCon];
    [self.view addSubview:_searchResultsViewCon.view];
    [_searchResultsViewCon.view easyFillSuperview];
}

- (void)dealloc
{
    _searchBar.delegate = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_searchBar resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)performSearch
{
    NSString* keyword = _searchBar.text;

    [SVProgressHUD showWithStatus:@"搜索中..." maskType:SVProgressHUDMaskTypeBlack];
    QJInterfaceManager *fm=[QJInterfaceManager sharedManager];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [fm requestImageSearchKey:keyword pageNum:1 pageSize:50 currentImageId:nil finished:^(NSArray * _Nonnull imageObjectArray, NSArray * _Nonnull resultArray, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_searchBar resignFirstResponder];
                [_searchResultsViewCon setKeyword:keyword withAssets:imageObjectArray];
                [SVProgressHUD dismiss];
            });
        }];
    });
}

@end
