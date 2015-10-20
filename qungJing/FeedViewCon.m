//
//  OWTFeedViewCon.m
//  Weitu
//
//  Created by Su on 3/10/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "FeedViewCon.h"
#import "OWTFeedItem.h"
#import "OWTAsset.h"
#import "OWTAssetViewCon.h"
#import "OWaterFlowLayout.h"
#import "OWTImageCell.h"
#import "OWTTabBarHider.h"
#import "ORefreshControl.h"
#import "OWaterFlowCollectionView.h"
#import "OWTAssetPagingViewCon.h"
#import "SVProgressHUD+WTError.h"
#import "UIView+EasyAutoLayout.h"
#import "RRConst.h"
#import <SVPullToRefresh/SVPullToRefresh.h>
#import <UIColor-HexString/UIColor+HexString.h>
#import "NetStatusMonitor.h"
#import "DealErrorPageViewController.h"

static NSString* kWaterFlowCellID = @"kWaterFlowCellID";

@interface FeedViewCon ()
{
    OWTFeed* _feed;
    OWTTabBarHider* _tabBarHider;
}

@property (nonatomic, strong) OWaterFlowLayout* waterFlowLayout;
@property (nonatomic, strong) UICollectionView* collectionView;

@property (nonatomic, strong) XHRefreshControl* refreshControl;
@property (nonatomic, strong) DealErrorPageViewController *vc;

@end

@implementation FeedViewCon

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
    _tabBarHider = [[OWTTabBarHider alloc] init];
}

- (void)dealloc
{
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = GetThemer().themeColorBackground;

    self.view.backgroundColor = GetThemer().themeColorBackground;
    _vc = [[DealErrorPageViewController alloc]init];
    [self addChildViewController:_vc];
    
    [self setupCollectionView];
    [self setupAltRefreshControl];

    [self reloadData];
}

- (void)setupCollectionView
{
    _waterFlowLayout = [[OWaterFlowLayout alloc] init];
    _waterFlowLayout.sectionInset = UIEdgeInsetsMake(5, 10, 5, 10);
    _waterFlowLayout.columnCount = 2;
    CGRect rect = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, SCREENHEI-64);
    _collectionView = [[OWaterFlowCollectionView alloc] initWithFrame:rect collectionViewLayout:_waterFlowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = GetThemer().themeColorBackground;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.alwaysBounceVertical = YES;
    
    [_collectionView registerClass:OWTImageCell.class forCellWithReuseIdentifier:kWaterFlowCellID];
    
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_collectionView];
//    [_collectionView easyFillSuperview];
}

- (void)setupAltRefreshControl
{
    _refreshControl = [[XHRefreshControl alloc] initWithScrollView:self.collectionView delegate:self];

    __weak FeedViewCon* wself = self;
    [_collectionView addInfiniteScrollingWithActionHandler:^{ [wself loadMoreFeedItems]; }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

//    [_tabBarHider showTabBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _refreshControl.originalTopInset = 0;

}

-(BOOL)navigationShouldPopOnBackButton
{
//    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
//    UIApplication *application = [UIApplication sharedApplication];
//    [application setStatusBarStyle:UIStatusBarStyleLightContent];
//    self.navigationController.navigationBar.barTintColor = GetThemer().homePageColor;
    [self.navigationController popViewControllerAnimated:YES];
    return YES;
}

#pragma mark - Actions

- (void)presentFeed:(OWTFeed*)feed animated:(BOOL)animated refresh:(BOOL)refresh
{
    if (feed == _feed)//内存地址一样？YES:NO
    {
        if (refresh)
        {
            [self manualRefresh];
        }
        return;
    }

    if (_feed == nil)
    {
        self.view.alpha = 0.0;
        _feed = feed;
        if (refresh)
        {
            [self reloadData];
            [self manualRefresh];
        }
        else
        {
            [self reloadData];
        }
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.view.alpha = 1.0;
                         }
                         completion:nil];
    }
    else
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.view.alpha = 0.0;
                         }
                         completion:^(BOOL isFinished) {
                             _feed = feed;

                             if (refresh)
                             {
                                 [self reloadData];
                                 [self manualRefresh];
                             }
                             else
                             {
                                 [self reloadData];
                             }

                             [_collectionView setContentOffset:CGPointMake(0, -self.collectionView.contentInset.top)];

                             [UIView animateWithDuration:0.3
                                              animations:^{
                                                  self.view.alpha = 1.0;
                                              }
                                              completion:nil];
                         }];
    }
}

- (NSInteger)numberOfItems
{
    if (_feed != nil)
    {
        return _feed.items.count;
    }
    else
    {
        return 0;
    }
}

- (OWTFeedItem*)itemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_feed != nil && indexPath != nil)
    {
        NSInteger row = indexPath.row;
        if (row < _feed.items.count)
        {
            return _feed.items[row];
        }
    }
    
    return nil;
}

#pragma mark - Refreshing related

- (void)manualRefreshIfNeeded
{
    if (_feed == nil)
    {
        return;
    }

    if (_feed.items.count == 0)
    {
        [self manualRefresh];
    }
}

- (void)manualRefresh
{
    [_refreshControl startPullDownRefreshing];
}

- (void)refreshFeed
{
    [_feed refreshWithSuccess:^{
        [self onRefreshDone];
        [_vc.view removeFromSuperview];
        
    }
                      failure:^(NSError* error) {
                          [self onRefreshDone];
                          __weak  FeedViewCon*  weakself = self;
                          //没有网络 并且当前页无缓存数据
                          if (![NetStatusMonitor isExistenceNetwork] && _feed.items.count<1) {
                              
                              [_vc.view removeFromSuperview];
                              _vc.getRefreshAction = ^{
                                  [weakself manualRefresh];
                              };
                              
                              [self.view addSubview:_vc.view];
                              return ;
                          }
                          [SVProgressHUD showError:error];
                      }];
}

- (void)onRefreshDone
{
    [_refreshControl endPullDownRefreshing];
    [self.collectionView reloadData];
}

- (void)loadMoreFeedItems
{
    [_feed loadMoreWithSuccess:^{ [self onLoadMoreDone]; }
                       failure:^(NSError* error) {
                           [self onLoadMoreDone];
                           [SVProgressHUD showError:error];
                       }];
}

- (void)onLoadMoreDone
{
    [self.collectionView reloadData];
    [_collectionView.infiniteScrollingView stopAnimating];
}

#pragma mark - Asset Displaying

- (void)displayAsset:(OWTAsset*)asset
{
    OWTAssetViewCon* assetViewCon = [[OWTAssetViewCon alloc] initWithAsset:asset deletionAllowed:YES onDeleteAction:^{ [self reloadData]; }];
    [self.navigationController pushViewController:assetViewCon animated:YES];
}

#pragma mark - Actions

- (void)reloadData
{
    [_collectionView reloadData];
}

#pragma mark - OWaterFlowLayoutDataSource

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    OWTFeedItem* item = [self itemAtIndexPath:indexPath];
    if (item != nil && item.asset != nil && item.asset.imageInfo != nil)
    {
        return item.asset.imageInfo.imageSize;
    }
    else
    {
        return CGSizeMake(1, 1);
    }
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self numberOfItems];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OWTImageCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kWaterFlowCellID forIndexPath:indexPath];
    
    OWTFeedItem* item = [self itemAtIndexPath:indexPath];
    if (item != nil)
    {
        if (item.asset.imageInfo != nil)
        {
            [cell setImageWithInfo:item.asset.imageInfo];
        }
        else
        {
            [cell setImageWithInfo:nil];
            cell.backgroundColor = [UIColor lightGrayColor];
        }
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark - UICollectionViewDelegate methods

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

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
    OWTFeedItem* item = [self itemAtIndexPath:indexPath];
    if (item != nil)
    {
        if ([_feed.feedID compare:@"Wallpaper" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            OWTAssetPagingViewCon* pagingViewCon = [[OWTAssetPagingViewCon alloc] initWithFeed:_feed];
            [self.navigationController pushViewController:pagingViewCon animated:YES];
            [pagingViewCon setInitialPageIndex:indexPath.row];
        }
        else
        {
            OWTAsset* asset = item.asset;
            [self displayAsset:asset];
        }
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

#pragma mark - 3rdparty refresh control

- (void)beginPullDownRefreshing
{
    [self refreshFeed];
}

- (void)beginLoadMoreRefreshing
{
    [self loadMoreFeedItems];
}

- (BOOL)keepiOS7NewApiCharacter
{
    return NO;
}

- (XHRefreshViewLayerType)refreshViewLayerType
{
    return XHRefreshViewLayerTypeOnScrollViews;
}

- (BOOL)isPullUpLoadMoreEnabled
{
    return YES;
}

@end
