//
//  OWTAssetFlowViewCon.m
//  Weitu
//
//  Created by Su on 6/14/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTAssetFlowViewCon.h"
#import "ORefreshControl.h"
#import "OWaterFlowLayout.h"
#import "OWTTabBarHider.h"
#import "OWaterFlowCollectionView.h"
#import "OWTImageCell.h"
#import "OWTAsset.h"
#import "UIView+EasyAutoLayout.h"
#import <SVPullToRefresh/SVPullToRefresh.h>


#import <SDWebImage/SDWebImageManager.h>
static NSString* kWaterFlowCellID = @"kWaterFlowCellID";

@interface OWTAssetFlowViewCon()
{
    OWTTabBarHider* _tabBarHider;
    UIBarButtonItem* _numItem;
}

@property (nonatomic, strong) OWaterFlowLayout* waterFlowLayout;
@property (nonatomic, strong) XHRefreshControl* refreshControl;


@end

@implementation OWTAssetFlowViewCon

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
    
    [self setupCollectionView];
    [self setupRefreshControl];

    [self reloadData];
}

- (void)setupCollectionView
{
    _waterFlowLayout = [[OWaterFlowLayout alloc] init];
    _waterFlowLayout.sectionInset = UIEdgeInsetsMake(5, 0, 5, 0);//第一个参数，是在视图上的高，第二个参数，是距左边的距离，第4个参数，是右边距离
    _waterFlowLayout.columnCount = 3;
    
    _collectionView = [[OWaterFlowCollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) collectionViewLayout:_waterFlowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = GetThemer().themeColorBackground;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.alwaysBounceVertical = YES;
    //
    _waterFlowLayout.sectionInset = UIEdgeInsetsMake(5, 0, 5, 0);//第一个参数，是在视图上的高，第二个参数，是距左边的距离，第4个参数，是右边距离
    _waterFlowLayout.columnCount = 3;
    

    //

    [_collectionView registerClass:OWTImageCell.class forCellWithReuseIdentifier:kWaterFlowCellID];

    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_collectionView];
//    [_collectionView easyFillSuperview];
}

- (void)setupRefreshControl
{
    _refreshControl = [[XHRefreshControl alloc] initWithScrollView:_collectionView delegate:self];

    __weak OWTAssetFlowViewCon* wself = self;
    [_collectionView addInfiniteScrollingWithActionHandler:^{ [wself loadMoreData]; }];
}

- (void)reloadData
{
    [_collectionView reloadData];
}

- (void)setTotalAssetNum:(NSNumber *)totalAssetNum
{
    _totalAssetNum = totalAssetNum;
    if (_totalAssetNum != nil)
    {
        if (self.parentViewController != nil &&
            (self.parentViewController.navigationItem.rightBarButtonItem == nil || self.parentViewController.navigationItem.rightBarButtonItem == _numItem))
        {
            if (_numItem == nil)
            {
                _numItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                            style:UIBarButtonItemStyleBordered
                                                           target:nil
                                                           action:nil];
                self.parentViewController.navigationItem.rightBarButtonItem = _numItem;
            }

            _numItem.title = [NSString stringWithFormat:@"%d", _totalAssetNum.integerValue];
        }
    }
}

- (void)manualRefresh
{
    [_refreshControl startPullDownRefreshing];
}

- (void)refreshData
{
    if (_refreshDataFunc == nil)
    {
        return;
    }

    _refreshDataFunc(^{
        [_refreshControl endPullDownRefreshing];
        [self reloadData];
    });
}

- (void)loadMoreData
{
    if (_loadMoreDataFunc == nil)
    {
        [_collectionView.infiniteScrollingView stopAnimating];
        return;
    }

    _loadMoreDataFunc(^
    {
        [self.collectionView reloadData];
        [_collectionView.infiniteScrollingView stopAnimating];
    });
}

#pragma mark - OWaterFlowLayoutDataSource

- (OWTAsset*)assetAtIndex:(NSInteger)index
{
    if (_assetAtIndexFunc == nil)
    {
        return nil;
    }
    
    return _assetAtIndexFunc(index);
}

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
//    static const CGSize kDummyItemSize = {1, 1};
//
//    OWTAsset* asset = [self assetAtIndex:indexPath.row];
//    if (asset == nil)
//    {
//        return kDummyItemSize;
//    }
//    
//    OWTImageInfo* imageInfo = asset.imageInfo;
//    if (imageInfo == nil)
//    {
//        return kDummyItemSize;
//    }
//
//    return imageInfo.imageSize;
    return CGSizeMake(100, 100);
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_numberOfAssetsFunc == nil)
    {
        return 0;
    }

    return _numberOfAssetsFunc();
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OWTImageCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kWaterFlowCellID forIndexPath:indexPath];

    OWTAsset* asset = [self assetAtIndex:indexPath.row];
    if (asset != nil)
    {
        OWTImageInfo* imageInfo = asset.imageInfo;
        if (imageInfo != nil)
        {
//            [cell setImageWithInfo:imageInfo];
            [cell.imageView setImageWithURL:[NSURL URLWithString:asset.imageInfo.smallURL] placeholderImage:[UIImage imageNamed:@""]];
            
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
    OWTAsset* asset = [self assetAtIndex:indexPath.row];
    if (asset != nil)
    {
        if (_onAssetSelectedFunc != nil)
        {
            _onAssetSelectedFunc(asset);
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
    [self refreshData];
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
    return NO;
}

@end
