//
//  OQJCategoryViewCon.m
//  Weitu
//
//  Created by Su on 8/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OQJExploreViewConlvyou.h"

#import "OWaterFlowCollectionView.h"
#import "OWaterFlowLayout.h"
#import "XHRefreshControl.h"
#import "OWTImageCell.h"
#import "OWTCategoryManagerlvyou.h"
#import "OWTCategoryViewCon.h"
#import "OWTSearchViewCon.h"
#import <FontAwesomeKit/FontAwesomeKit.h>

#import "UIView+EasyAutoLayout.h"
#import "SVProgressHUD+WTError.h"
#import <SVPullToRefresh/SVPullToRefresh.h>
#import "RRConst.h"
#import "NetStatusMonitor.h"
#import "DealErrorPageViewController.h"
static NSString* kWaterFlowCellID = @"kWaterFlowCellID";

@interface OQJExploreViewConlvyou ()

@property (nonatomic, strong) OWaterFlowLayout* waterFlowLayout;
@property (nonatomic, strong) XHRefreshControl* refreshControl;
@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, copy) NSArray* categories;
@property (nonatomic, strong)DealErrorPageViewController *vc;
@end

@implementation OQJExploreViewConlvyou

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    OWTCategoryManagerlvyou *ocm = [[OWTCategoryManagerlvyou alloc ]init];
    //ocm.keyPath =@"categories/app";
    
    [super viewDidLoad];
    
    [self setupNavigationBar];
    [self setupCollectionView];
    [self setupRefreshControl];
    
    [self setupSubViewController];
    [self reloadData];
}

-(void)setupSubViewController
{
    _vc= [[DealErrorPageViewController alloc]init];
    [self addChildViewController:_vc];
    
}
- (void)setupNavigationBar
{
    self.view.backgroundColor = GetThemer().themeColorBackground;
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , 100, 44)];
    
    //titleLabel.text = @"首页";
    titleLabel.backgroundColor = [UIColor clearColor];  //设置Label背景透明
    //titleLabel.font = [UIFont boldSystemFontOfSize:20];  //设置文本字体与大小
    titleLabel.textColor = GetThemer().themeColor;  //设置文本颜色
    titleLabel.textAlignment = UITextAlignmentCenter;
    //self.navigationItem.titleView = titleLabel;
    
    UIImage* searchImage = [[FAKFontAwesome searchIconWithSize:22] imageWithSize:CGSizeMake(22, 22)];
    searchImage = [searchImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    　
}

-(BOOL) navigationShouldPopOnBackButton ///在这个方法里写返回按钮的事件处理
{
//    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
//    UIApplication *application = [UIApplication sharedApplication];
//    [application setStatusBarStyle:UIStatusBarStyleLightContent];
//    self.navigationController.navigationBar.barTintColor = GetThemer().homePageColor;
    [self.navigationController popViewControllerAnimated:YES];
    return YES;
}
- (void)setupCollectionView
{
    _waterFlowLayout = [[OWaterFlowLayout alloc] init];
    _waterFlowLayout.sectionInset = UIEdgeInsetsMake(6, 0, 6, 0);
    _waterFlowLayout.minimumColumnSpacing = 6;
    _waterFlowLayout.minimumInteritemSpacing = 6;
    _waterFlowLayout.columnCount = 2;
    
    _collectionView = [[OWaterFlowCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:_waterFlowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = GetThemer().themeColorBackground;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.alwaysBounceVertical = YES;
    
    [_collectionView registerClass:OWTImageCell.class forCellWithReuseIdentifier:kWaterFlowCellID];
    
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_collectionView];
    [_collectionView easyFillSuperview];
}

- (void)setupRefreshControl
{
    _refreshControl = [[XHRefreshControl alloc] initWithScrollView:_collectionView delegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshIfNeeded];
}

- (void)search
{
    OWTSearchViewCon* searchViewCon = [[OWTSearchViewCon alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:searchViewCon animated:YES];
}

- (void)refreshIfNeeded
{
    OWTCategoryManagerlvyou* cm = GetCategoryManagerlvyou();
    if (cm.isRefreshNeeded)
    {
        [self manualRefresh];
    }
}

- (void)manualRefresh
{
    [_refreshControl startPullDownRefreshing];
}

- (void)refresh
{
    OWTCategoryManagerlvyou* cm = GetCategoryManagerlvyou();
    [_vc.view removeFromSuperview];
    [cm refreshCategoriesWithSuccess:^{
        [_refreshControl endPullDownRefreshing];
        [self reloadData];
    }
                             failure:^(NSError* error) {
                                 [_refreshControl endPullDownRefreshing];
                                 __weak  OQJExploreViewConlvyou*  weakself = self;
                                 //没有网络 并且当前页无缓存数据
                                 if (![NetStatusMonitor isExistenceNetwork] && _categories.count<1) {
                                     
                                     _vc.getRefreshAction = ^{
                                         [weakself manualRefresh];
                                     };
                                     
                                     [self.view addSubview:_vc.view];
                                     return ;
                                 }
                                 
                                 [SVProgressHUD showError:error];
                             }];
}

- (void)reloadData
{
    _categories = GetCategoryManagerlvyou().categories;
    [_collectionView reloadData];
}

#pragma mark - OWaterFlowLayoutDataSource

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    return CGSizeMake(157, 178);
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _categories.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OWTImageCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kWaterFlowCellID forIndexPath:indexPath];
    
    OWTCategory* category = _categories[indexPath.row];
    [cell setImageWithInfo:category.coverImageInfo];
    
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
    OWTCategory* category = _categories[indexPath.row];
    OWTCategoryViewCon* categoryViewCon = [[OWTCategoryViewCon alloc] initWithCategory:category];
    [self.navigationController pushViewController:categoryViewCon animated:YES];
}

#pragma mark - 3rdparty refresh control

- (void)beginPullDownRefreshing
{
    [self refresh];
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
