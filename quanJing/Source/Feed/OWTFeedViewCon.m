//
//  OWTFeedViewCon.m
//  Weitu
//
//  Created by Su on 3/10/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTFeedViewCon.h"
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
#import <SVPullToRefresh/SVPullToRefresh.h>
#import <UIColor-HexString/UIColor+HexString.h>

#import "OQJSelectedViewCon.h"
#import "OQJExploreViewConlvyou.h"
#import "OQJExploreViewGeneral.h"
#import "OQJExploreViewConlvyouinternational.h"
#import "OWTCategoryViewCon.h"
#import "OQJSelectedViewCon.h"

#import "OWTCategoryManagerlife.h"
#import "OWTUserManager.h"


#import "MBProgressHUD.h"
#import "NetStatusMonitor.h"

#define DISTSCROVIEW 45

static NSString* kWaterFlowCellID = @"kWaterFlowCellID";

@interface OWTFeedViewCon ()
{
    OWTFeed* _feed;
    OWTTabBarHider* _tabBarHider;
    BOOL ifFirstEnter;
    OWTUser *_user;
    NSMutableData *localCacheData;
    MBProgressHUD * _progress;
    NSMutableData *_topData;
}

@property (nonatomic, strong) OWaterFlowLayout* waterFlowLayout;

@property (nonatomic, strong) XHRefreshControl* refreshControl;
@property (nonatomic, strong) JCTopic* Topic;
@property (nonatomic, copy) NSArray* categories;


@end

@implementation OWTFeedViewCon

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
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
}

- (void)dealloc
{
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}


//自己添加
-(void)setupJCTopic
{
    NSURL *url = [NSURL URLWithString:@"http://api.tiankong.com/qjapi/cdn2/HomeRotation"];
    
    NSError *error;
    
    NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    
    NSLog(@"jsonString =%@",jsonString);
    
    //利用三方解析json数据
    
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    
    NSURLConnection *connection=[NSURLConnection connectionWithRequest:request delegate:self];

    _showArr = [[NSMutableArray alloc]init];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [_topData setLength:0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_topData appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSMutableArray * tempArray = [[NSMutableArray alloc]init];
    NSArray *Arr =[NSJSONSerialization JSONObjectWithData:_topData options:NSJSONReadingMutableLeaves error:nil];
    NSString *homeDictionary = NSHomeDirectory();//获取根目录
    NSString *homePath  = [homeDictionary stringByAppendingString:@"/Documents/atany2.archiver"];
    BOOL ret=[NSKeyedArchiver archiveRootObject:Arr toFile:homePath];
    for (NSDictionary*appdict in Arr) {
        
        
        NSString *str =[appdict objectForKey:@"ImgUrl"];
        [tempArray addObject:[NSDictionary dictionaryWithObjects:@[str,@" ",@NO] forKeys:@[@"pic",@"title",@"isLoc"]]];
        
        
        [_showArr addObject:appdict];
        
    }
    //加入数据 轮播图URL地址
    _Topic.pics = tempArray;
    _Topic.picsDic = Arr;
    _Topic.ifHomePage = YES;
    _Topic.page = _page;
    [_Topic upDate];
    _page.numberOfPages = tempArray.count;
}
-(void)setUpTopic
{
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, DISTSCROVIEW-3, 320, 160)];
    //实例化
    _Topic = [[JCTopic alloc]initWithFrame:CGRectMake(0, 0, 320, 160+5+3)];
    //代理
    _Topic.JCdelegate = self;
    _Topic.progress = _progress;
    [_Topic addSubview:_page];
    [view addSubview:_Topic];
    [_collectionView addSubview:view];
    [_collectionView addSubview:_page];
    NSMutableArray * tempArray = [[NSMutableArray alloc]init];
    NSString *homeDictionary = NSHomeDirectory();//获取根目录
    NSString *homePath  = [homeDictionary stringByAppendingString:@"/Documents/atany2.archiver"];//添加储存的文件名
    NSArray *Arr=[NSKeyedUnarchiver unarchiveObjectWithFile:homePath];
    if (Arr==nil) {
        return;
    }
    for (NSDictionary*appdict in Arr) {
        
        
        NSString *str =[appdict objectForKey:@"ImgUrl"];
        [tempArray addObject:[NSDictionary dictionaryWithObjects:@[str,@" ",@NO] forKeys:@[@"pic",@"title",@"isLoc"]]];
        
        
        [_showArr addObject:appdict];
        
    }
    
    //加入数据 轮播图URL地址
    _Topic.pics = tempArray;
    _Topic.picsDic = Arr;
    _Topic.ifHomePage = YES;
    _Topic.page = _page;
    NSLog(@"tempArray: %@",tempArray);
    //更新
    [_Topic upDate];
    _page.numberOfPages = tempArray.count;//指定页面个数
}
-(void)currentPage:(int)page total:(NSUInteger)total{
    // _label1.text = [NSString stringWithFormat:@"图片 Page %d",page+1];
    _page.numberOfPages = total;
    _page.currentPage = page;
}

-(void)didClick:(id)data{
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_tabBarHider showTabBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    OWTCategoryManagerlife* cm = GetCategoryManagerlife();
    if (cm.isRefreshNeeded)
    {
        [self manualRefresh];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   // self.view.backgroundColor = GetThemer().themeTintColor;
    [self setupCollectionView];
    [self setupAltRefreshControl];
    _topData=[[NSMutableData alloc]init];
    _progress = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_progress];
    [_progress show:YES];
    _page =[[UIPageControl alloc] initWithFrame:CGRectMake(140, 150+DISTSCROVIEW, 40, 5+8)];
    
    
    _page.currentPage = 0;//指定pagecontroll的值，默认选中的小白点（第一个）
    _page.currentPageIndicatorTintColor = [UIColor blueColor];
    [_page setHidden:YES];
    [self setUpTopic];
    [self setupJCTopic];
    OWTCategoryManagerlife* cm = GetCategoryManagerlife();
[cm getResouceData:^{
    [self reloadData];
}];
    
    //[self reloadData];
}


- (void)setupCollectionView
{
    _waterFlowLayout = [[OWaterFlowLayout alloc] init];
    _waterFlowLayout.sectionInset = UIEdgeInsetsMake(170+DISTSCROVIEW-10+8, 0, 5, -1);
    _waterFlowLayout.columnCount = 2;
    _waterFlowLayout.minimumColumnSpacing = 5;
    _waterFlowLayout.minimumInteritemSpacing = 5;

    _collectionView = [[OWaterFlowCollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height+5-60-22-25) collectionViewLayout:_waterFlowLayout];
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
    
}



- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _refreshControl.originalTopInset = 0;
}


- (OWTCategory*)itemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_categories != nil && indexPath != nil)
    {
        NSInteger row = indexPath.row;
        
        OWTCategory *categories = _categories[row];
        //if (row < _feed.items.count)
        //{
        return categories;
        //}
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
    OWTCategoryManagerlife* cm = GetCategoryManagerlife();
    [cm refreshCategoriesWithSuccess:^{
        [_refreshControl endPullDownRefreshing];
        [self reloadData];
    }
                             failure:^(NSError* error) {
                                 [_refreshControl endPullDownRefreshing];
                                 //如果是下啦刷新 并且失败
                                 if (![NetStatusMonitor isExistenceNetwork]) {
                                     [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
                                     return;
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
    _categories = GetCategoryManagerlife().categories;
    NSLog(@"尼玛_categories  %@",_categories);
    [_collectionView reloadData];
}

#pragma mark - OWaterFlowLayoutDataSource

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    //OWTFeedItem* item = [self itemAtIndexPath:indexPath];
    OWTCategory* category = [self itemAtIndexPath:indexPath];
    OWTImageInfo *imageInfo = category.coverImageInfo;
    if (category != nil  && imageInfo != nil)
    {
        return CGSizeMake(157, 178);
    }
    else
    {
        return CGSizeMake(1, 1);
    }
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
    
    //OWTFeedItem* item = [self itemAtIndexPath:indexPath];
    OWTCategory* category = [self itemAtIndexPath:indexPath];
    OWTImageInfo *imageInfo = category.coverImageInfo;
    if (category != nil)
    {
        if (imageInfo!= nil)
        {
            [cell setImageWithInfo:category.coverImageInfo];
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
//colleview点击事件
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [_tabBarHider hideTabBar];
    OWTCategory* category = [self itemAtIndexPath:indexPath];
    //旅游的跳转页面
    if ([category.categoryName containsString:@"国内旅游"]) {
        
        OQJExploreViewConlvyou* hottestViewCon = [[OQJExploreViewConlvyou alloc] init];
        hottestViewCon.title = category.categoryName;
        hottestViewCon.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:hottestViewCon animated:YES];
        return;
    }
    if ([category.categoryName containsString:@"国外旅游"]) {
        
        OQJExploreViewConlvyouinternational* latestViewCon = [[OQJExploreViewConlvyouinternational alloc] init];
        latestViewCon.hidesBottomBarWhenPushed = YES;

        latestViewCon.title = category.categoryName;
        [self.navigationController pushViewController:latestViewCon animated:YES];
        return;
        
    }

    if ([category.categoryName containsString:@"家居"]) {
        
        OQJExploreViewGeneral* hottestViewCon = [[OQJExploreViewGeneral alloc] init];
        hottestViewCon.hidesBottomBarWhenPushed = YES;
        hottestViewCon.title = category.categoryName;
        hottestViewCon.VcTag = 2;

        [self.navigationController pushViewController:hottestViewCon animated:YES];
        return;
    }
    if ([category.categoryName containsString:@"汽车"]) {
        
        OQJExploreViewGeneral* hottestViewCon = [[OQJExploreViewGeneral alloc] init];
        hottestViewCon.title = category.categoryName;
        hottestViewCon.VcTag = 4;
        hottestViewCon.hidesBottomBarWhenPushed = YES;

        [self.navigationController pushViewController:hottestViewCon animated:YES];
        return;
    }
    if ([category.categoryName containsString:@"美食"]) {
        
        OQJExploreViewGeneral* hottestViewCon = [[OQJExploreViewGeneral alloc] init];
        hottestViewCon.title = category.categoryName;
        hottestViewCon.VcTag = 3;
        hottestViewCon.hidesBottomBarWhenPushed = YES;

        [self.navigationController pushViewController:hottestViewCon animated:YES];
        return;
    }
    if ([category.categoryName containsString:@"时尚"]) {
        
        OQJExploreViewGeneral* hottestViewCon = [[OQJExploreViewGeneral alloc] init];
        hottestViewCon.title = category.categoryName;
        hottestViewCon.VcTag = 1;
        hottestViewCon.hidesBottomBarWhenPushed = YES;

        [self.navigationController pushViewController:hottestViewCon animated:YES];
        return;
    }
    NSLog(@"feedID =%@",category.feedID);
    NSString *url =[NSString stringWithFormat:@"http://api.tiankong.com/qjapi/cdn2/feeds/%@",category.feedID];
    NSLog(@"%@",url);
    OWTCategoryViewCon* categoryViewCon = [[OWTCategoryViewCon alloc] initWithCategory:category];
    categoryViewCon.hidesBottomBarWhenPushed = YES;
    categoryViewCon.ifNeedSetbackground = YES;
    [self.navigationController pushViewController:categoryViewCon animated:YES];
    
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
