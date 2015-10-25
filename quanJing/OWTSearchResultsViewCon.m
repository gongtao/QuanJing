//
//  OWTSearchResultsViewCon.m
//  Weitu
//
//  Created by Su on 7/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTSearchResultsViewCon.h"

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
#import "QuanJingSDK.h"
static NSString* kWaterFlowCellID = @"kWaterFlowCellID";

@interface OWTSearchResultsViewCon ()
{
    OWTTabBarHider* _tabBarHider;
}

@property (nonatomic, strong) NSString* keyword;
@property (nonatomic, strong) NSMutableOrderedSet* assets;
@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) OWaterFlowLayout* collectionViewLayout;

@end

@implementation OWTSearchResultsViewCon

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _tabBarHider = [[OWTTabBarHider alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupCollectionView];
    [self setupRefreshControl];
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
    __weak OWTSearchResultsViewCon* wself = self;
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
    [SVProgressHUD show];
    _keyword = [keyword copy];
    self.title = keyword;
    _assets = [[NSMutableOrderedSet alloc]init];
    [self loadMoreData];
    [_collectionView setContentOffset:CGPointMake(0, -self.collectionView.contentInset.top) animated:YES];

}

- (void)setKeyword:(NSString *)keyword withAssets:(NSArray*)assets
{
    _keyword = [keyword copy];
    self.title = keyword;
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
    QJInterfaceManager *fm=[QJInterfaceManager sharedManager];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [fm requestImageSearchKey:_keyword pageNum:_assets.count/50+1 pageSize:50 currentImageId:nil finished:^(NSArray * _Nonnull imageObjectArray, NSArray * _Nonnull resultArray, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (imageObjectArray.count==0) {
                    [SVProgressHUD showErrorWithStatus:@"没有找到图片"];
                }
                [_collectionView.infiniteScrollingView stopAnimating];
                [self mergeAssets:imageObjectArray];
                [SVProgressHUD dismiss];
    
            });
            }];
    });
//    OWTSearchManager* sm = GetSearchManager();
//    [sm searchAssetsWithKeyword:_keyword
//                     startIndex:_assets.count
//                          count:50
//                        success:^(NSArray* assets) {
//                            [_collectionView.infiniteScrollingView stopAnimating];
//                            [self mergeAssets:assets];
//                            [SVProgressHUD dismiss];
//                        }
//                        failure:^(NSError* error) {
//                            [_collectionView.infiniteScrollingView stopAnimating];
//                            [SVProgressHUD showError:error];
//                        }];
}

#pragma mark - OWaterFlowLayoutDataSource

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    QJImageObject *model= _assets[indexPath.row];
    if (model != nil)
    {
        return CGSizeMake(model.width.intValue,model.height.intValue);
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
    QJImageObject *model=_assets[indexPath.row];
    OWTImageInfo *imageInfo=[[OWTImageInfo alloc]init];
    imageInfo.url=model.url;
    imageInfo.width=model.width.intValue;
    imageInfo.height=model.height.intValue;
    imageInfo.primaryColorHex=model.bgcolor;
    if (model != nil)
    {
        if (imageInfo != nil)
        {
            [cell setImageWithInfo:imageInfo];
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
    QJImageObject *model=_assets[indexPath.row];
    if (model != nil)
    {
        OWTAssetViewCon *assetViewCon=[[OWTAssetViewCon alloc]initWithImageId:model.imageId imageType:[NSNumber numberWithInt:1]];
//        OWTAssetViewCon* assetViewCon = [[OWTAssetViewCon alloc] initWithAsset:asset deletionAllowed:YES onDeleteAction:^{ [self.collectionView reloadData]; }];
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

@end
