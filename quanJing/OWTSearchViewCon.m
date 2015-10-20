//
//  OWTSearchResultsViewCon.m
//  Weitu
//
//  Created by Su on 7/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//
#import "OWTSearchViewCon.h"


#import "OWTAsset.h"
#import "OWTAssetViewCon.h"
#import "OWaterFlowLayout.h"
#import "OWTImageCell.h"
#import "OWTTabBarHider.h"
#import "UIViewController+WTExt.h"
#import "OWTSearchManager.h"
#import "SVProgressHUD+WTError.h"
#import "UIView+EasyAutoLayout.h"
#import <SVPullToRefresh/SVPullToRefresh.h>

#import "UISearchBar+Blocks.h"
static NSString* kWaterFlowCellID = @"kWaterFlowCellID";

@interface OWTSearchViewCon ()
{
    OWTTabBarHider* _tabBarHider;
}

@property (nonatomic, strong) NSString* keyword;
@property (nonatomic, strong) NSMutableOrderedSet* assets;
@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) OWaterFlowLayout* collectionViewLayout;
@property (nonatomic, strong) UISearchBar* searchBar;

@end

@implementation OWTSearchViewCon

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        //        _tabBarHider = [[OWTTabBarHider alloc] init];
        //        [self setupSearchBar];
        
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self setupSearchBar];
    [self setupCollectionView];
    [self setupRefreshControl];
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
    [_searchBar becomeFirstResponder];
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


- (void)setupCollectionView
{
    _collectionViewLayout = [[OWaterFlowLayout alloc] init];
    _collectionViewLayout.sectionInset = UIEdgeInsetsMake(5, 10, 5, 10);
    _collectionViewLayout.columnCount = 2;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                             collectionViewLayout:_collectionViewLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.view addSubview:_collectionView];
    [_collectionView easyFillSuperview];
    
    self.view.backgroundColor = GetThemer().themeColorBackground;
    
    [self.collectionView registerClass:OWTImageCell.class forCellWithReuseIdentifier:kWaterFlowCellID];
    
    self.collectionView.backgroundColor = GetThemer().themeColorBackground;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    self.collectionView.alwaysBounceVertical = YES;
}

- (void)setupRefreshControl
{
    __weak OWTSearchViewCon* wself = self;
    [_collectionView addInfiniteScrollingWithActionHandler:^{ [wself loadMoreData]; }];
}

- (void)dealloc
{
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self substituteNavigationBarBackItem];
}

- (void)setKeyword:(NSString *)keyword
{
}

- (void)setKeyword:(NSString *)keyword withAssets:(NSArray*)assets
{
    _keyword = [keyword copy];
    self.title = keyword;

//    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 100, 44)];
//    label.text = [NSString stringWithFormat:@"%@",keyword];
//    label.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:24];
//    
//    [label setTextAlignment:NSTextAlignmentCenter];
//    label.textColor = GetThemer().themeTintColor;
//    self.navigationItem.titleView =label;
    
    _assets = [NSMutableOrderedSet orderedSetWithArray:assets];
    [self.collectionView reloadData];
    [_collectionView setContentOffset:CGPointMake(0, -self.collectionView.contentInset.top) animated:YES];
}

- (void)mergeAssets:(NSArray*)assets
{
    [_assets addObjectsFromArray:assets];
    [_collectionView reloadData];
}

- (void)loadMoreData
{
    OWTSearchManager* sm = GetSearchManager();
    [sm searchAssetsWithKeyword:_keyword
                     startIndex:_assets.count
                          count:50
                        success:^(NSArray* assets) {
                            [_collectionView.infiniteScrollingView stopAnimating];
                            [self mergeAssets:assets];
                        }
                        failure:^(NSError* error) {
                            [_collectionView.infiniteScrollingView stopAnimating];
                            [SVProgressHUD showError:error];
                        }];
}

#pragma mark - OWaterFlowLayoutDataSource

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    OWTAsset* asset = _assets[indexPath.row];
    if (asset != nil && asset.imageInfo != nil)
    {
        return asset.imageInfo.imageSize;
    }
    else
    {
        return CGSizeZero;
    }
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_assets != nil)
    {
        return _assets.count;
    }
    else
    {
        return 0;
    }
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OWTImageCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kWaterFlowCellID forIndexPath:indexPath];
    
    OWTAsset* asset = _assets[indexPath.row];
    if (asset != nil)
    {
        if (asset.imageInfo != nil)
        {
            [cell setImageWithInfo:asset.imageInfo];
        }
        else
        {
            cell.backgroundColor = [UIColor lightGrayColor];
        }
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate methods

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// called when the user taps on an already-selected item in multi-select mode
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    OWTAsset* asset = _assets[indexPath.row];
    if (asset != nil)
    {
        OWTAssetViewCon* assetViewCon = [[OWTAssetViewCon alloc] initWithAsset:asset deletionAllowed:YES onDeleteAction:^{ [self.collectionView reloadData]; }];
        [self.navigationController pushViewController:assetViewCon animated:YES];
    }
}

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_tabBarHider notifyScrollViewWillBeginDraggin:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_tabBarHider notifyScrollViewDidScroll:scrollView];
}
- (void)performSearch
{
    __weak OWTSearchViewCon* wself = self;
    
    NSString* keyword = _searchBar.text;
    
    [SVProgressHUD showWithStatus:@"搜索中..." maskType:SVProgressHUDMaskTypeBlack];
    
    OWTSearchManager* sm = GetSearchManager();
    [sm searchAssetsWithKeyword:keyword
                        success:^(NSArray* assets) {
                            [_searchBar resignFirstResponder];
                            [wself setKeyword:keyword withAssets:assets];
                            [SVProgressHUD dismiss];
                        }
                        failure:^(NSError* error) {
                            [SVProgressHUD showError:error];
                        }];
}

@end
