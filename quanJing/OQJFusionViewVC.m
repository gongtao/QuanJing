//
//  OQJFusionViewVC.m
//  Weitu
//
//  Created by denghs on 15/9/18.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OQJFusionViewVC.h"
#import "OWaterFlowCollectionView.h"
#import "OWaterFlowLayout.h"
#import "XHRefreshControl.h"
#import "OWTImageCell.h"

#import "OWTCategoryManagerqiche.h"
#import "OWTCategoryManagershishang.h"
#import "OWTCategoryManagermeishi.h"
#import "OWTCategoryManagerjiaju.h"
#import "OWTCategoryManagerlvyou.h"

#import "OWTCategoryViewCon.h"
#import "OWTSearchViewCon.h"
#import <FontAwesomeKit/FontAwesomeKit.h>

#import "UIView+EasyAutoLayout.h"
#import "SVProgressHUD+WTError.h"
#import <SVPullToRefresh/SVPullToRefresh.h>
#import "NetStatusMonitor.h"
#import "DealErrorPageViewController.h"
#import "OWTTabBarHider.h"
#import "OWTCategoryData.h"
#import "OWTCategory.h"
#import "OWTFeedManager.h"
#import "OWTFeedItem.h"
#import "OWTAsset.h"
#import "OWTAssetPagingViewCon.h"
#import "OWTAssetViewCon.h"
#import "OWTSearchResultsViewCon.h"
#import "UIColor+HexString.h"
#import "LJSearchViewController.h"
#import "RRConst.h"
#import "OWTCategoryManagerbaike.h"

#define DISTSCROVIEW 10
static NSString* kWaterFlowCellID = @"kWaterFlowCellID";

@interface OQJFusionViewVC()

@property (nonatomic, strong) OWaterFlowLayout* waterFlowLayout;
@property (nonatomic, strong) XHRefreshControl* refreshControl;
@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, copy) NSArray* categories;
@property (nonatomic, strong) DealErrorPageViewController *vc;
@property (nonatomic, strong) OWTTabBarHider* tabBarHider;
@property (nonatomic, strong)FusionScrollView  *fusionScrollView ;
@property (nonatomic, strong)OWTCategoryData *defalutfeed;
@property (nonatomic, readonly) OWTFeed* feed;
@property (nonatomic, strong)UITextField * keywordTextField;
@property (nonatomic, strong)UISearchBar *searchBar;
@property (nonatomic, strong)UITapGestureRecognizer *tap;
@property (nonatomic, strong)NSString *currentTrigle;
@property (nonatomic, assign)BOOL isFirst;
@property (nonatomic, strong)UIVisualEffectView *effectView;




@end

@implementation OQJFusionViewVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // [self setup];
    }
    return self;
}

- (void)setup
{
    _tabBarHider = [[OWTTabBarHider alloc] init];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _vc = [[DealErrorPageViewController alloc]init];
    _defalutfeed = [[OWTCategoryData alloc]init];
    
    [self addChildViewController:_vc];
    //初始化 scrowView 或加载本地数据
    [self setupCollectionView];
    
    [self setupRefreshControl];
    
    [self setUpTopic];
    [self setUpsearchView];
    self.view.backgroundColor = HWColor(242, 242, 242);
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    _effectView = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    _effectView.frame = CGRectMake(0, 0, (SCREENWIT-5)/4-5, (SCREENWIT-25)/4);
    _effectView.alpha = 0.3;
}


-(void)setUpsearchView
{

    _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(-20, 0, SCREENWIT-50, 40)];
    _searchBar.delegate=self;
    _searchBar.placeholder=@"搜索";
    [_searchBar setContentMode:UIViewContentModeLeft];
    _searchBar.userInteractionEnabled=YES;

    [_searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"_0004_圆角矩形-5"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)]
                                     forState:UIControlStateNormal];
    //_searchBar
    [_searchBar.layer setBorderColor:[UIColor redColor].CGColor];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onSearchTap)];
    [_searchBar addGestureRecognizer:tap];

    self.navigationItem.titleView = _searchBar;
    
    [self changeSearchBarBackcolor:_searchBar];
    
    
}


-(void)changeSearchBarBackcolor:(UISearchBar *)mySearchBar
{
    
    UITextField *txfSearchField = [mySearchBar valueForKey:@"_searchField"];
    txfSearchField.clearButtonMode = UITextFieldViewModeNever;
    mySearchBar.text = @"搜索";
    txfSearchField.textColor = [UIColor whiteColor];
    [txfSearchField setValue:[UIFont boldSystemFontOfSize:12] forKeyPath:@"_placeholderLabel.font"];
    
    mySearchBar.barTintColor = [UIColor whiteColor];
    txfSearchField = [[[mySearchBar.subviews firstObject] subviews] lastObject];
    
}

#pragma mark searchDelegate
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    //    [searchBar endEditing:YES];
    LJSearchViewController *lvc=[[LJSearchViewController alloc]init];
    lvc.hidesBottomBarWhenPushed=YES;
    [_tabBarHider hideTabBar];
    [self.navigationController pushViewController:lvc animated:NO];
}


- (void)performSearch
{
    NSString* keyword = _searchBar.text;
    OWTSearchResultsViewCon* searchResultsViewCon = [[OWTSearchResultsViewCon alloc] initWithNibName:nil bundle:nil];
    searchResultsViewCon.view.tag = 8173;
    self.navigationController.navigationBar.barTintColor = nil;
    [searchResultsViewCon setKeyword:keyword ];
    searchResultsViewCon.hidesBottomBarWhenPushed = YES;
//    [searchResultsViewCon substituteNavigationBarBackItem];
    UIApplication *application = [UIApplication sharedApplication];
    [application setStatusBarStyle:UIStatusBarStyleDefault];
    [_tabBarHider hideTabBar];
    [self.navigationController pushViewController:searchResultsViewCon animated:YES];
    _searchBar.text = nil;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                    // called when
{
    [self performSearch];
    [_searchBar resignFirstResponder];
    _searchBar.text = @"";
    
}

#pragma mark tapAndButton
-(void)onSearchTap 
{
    LJSearchViewController *lvc=[[LJSearchViewController alloc]init];
    lvc.hidesBottomBarWhenPushed=YES;
    //[_tabBarHider hideTabBar];
    [self.navigationController pushViewController:lvc animated:NO];
}

// 点击背景隐藏
-(void)tapToHidePopView
{
    _tap.enabled = false;
    [_searchBar resignFirstResponder];
    _searchBar.text = @"";
}


- (void)setupCollectionView
{
    _waterFlowLayout = [[OWaterFlowLayout alloc] init];
    _waterFlowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 5, 5);
    _waterFlowLayout.minimumColumnSpacing = 6;
    _waterFlowLayout.minimumInteritemSpacing = 6;
    _waterFlowLayout.columnCount = 2;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 95, SCREENWIT, SCREENHEI-95-40-20)];
    _collectionView = [[OWaterFlowCollectionView alloc] initWithFrame:view.bounds collectionViewLayout:_waterFlowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = GetThemer().themeColorBackground;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.alwaysBounceVertical = YES;
    [_collectionView registerClass:OWTImageCell.class forCellWithReuseIdentifier:kWaterFlowCellID];
    
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [view addSubview:_collectionView];
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview: view];
    [_collectionView easyFillSuperview];
}

- (void)setupRefreshControl
{
    _refreshControl = [[XHRefreshControl alloc] initWithScrollView:_collectionView delegate:self];
    __weak OQJFusionViewVC *wself = self;
    [_collectionView addInfiniteScrollingWithActionHandler:^{ [wself loadMoreFeedItems]; }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_tabBarHider showTabBar];
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self manualRefresh];
    
    
}

- (void)loadMoreFeedItems
{
    if (_feed == nil) {
        return;
    }
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

- (void)refreshIfNeeded
{
    if (self.VcTag == 5) {
        OWTCategoryManagershishang* cm = GetCategoryManagershishang();
        _defalutfeed = [cm.categories firstObject];
        
        if (cm.isRefreshNeeded)
        {
            [self manualRefresh];
            return;
            
        }
    }
    if (self.VcTag == 2) {
        OWTCategoryManagerjiaju* cm = GetCategoryManagerjiaju();
        _defalutfeed = [cm.categories firstObject];
        
        if (cm.isRefreshNeeded)
        {
            [self manualRefresh];
            return;
            
        }
    }
    
    if (self.VcTag == 6) {
        OWTCategoryManagerbaike* cm = GetCategoryManagerbaike();
        _defalutfeed = [cm.categories firstObject];
        
        if (cm.isRefreshNeeded)
        {
            [self manualRefresh];
            return;
            
        }
    }
    
    if (self.VcTag == 4) {
        
        OWTCategoryManagermeishi *cm = GetCategoryManagermeishi();
        _defalutfeed = [cm.categories firstObject];
        
        if (cm.isRefreshNeeded)
        {
            [self manualRefresh];
            return;
            
        }
    }
    if (self.VcTag == 3) {
        OWTCategoryManagerqiche* cm = GetCategoryManagerqiche();
        _defalutfeed = [cm.categories firstObject];
        if (cm.isRefreshNeeded)
        {
            [self manualRefresh];
            return;
            
        }
    }
    
    if (self.VcTag == 1) {
        OWTCategoryManagerlvyou* cm = GetCategoryManagerlvyou();
        _defalutfeed = [cm.categories firstObject];
        
        if (cm.isRefreshNeeded)
        {
            [self manualRefresh];
            return;
        }
    }
    
    [self getsubByFeedId];
}

- (void)manualRefresh
{
    [_refreshControl startPullDownRefreshing];
}

- (void)refresh
{
    __weak  OQJFusionViewVC*  weakself = self;
    
    if (self.VcTag == 1) {
        OWTCategoryManagerlvyou* cm = GetCategoryManagerlvyou();
        if (!_isFirst) {
            _defalutfeed = [cm.categories firstObject];
            _isFirst = YES;
        }
        [self reloadData];
        
        if (cm.isRefreshNeeded)
        {
            [cm refreshCategoriesWithSuccess:^{
                _contentType = @"lvyou";
                _defalutfeed = [cm.categories firstObject];
                [self reloadData];
            }
                                     failure:^(NSError* error) {
                                         [_refreshControl endPullDownRefreshing];
                                         
                                         //没有网络 并且当前页无缓存数据
                                         if (![NetStatusMonitor isExistenceNetwork] && _categories.count<1) {
                                             
                                             [_vc.view removeFromSuperview];
                                             _vc.getRefreshAction = ^{
                                                 [weakself manualRefresh];
                                             };
                                             /*网络错误刷新已关闭, 最后解开*/
                                             //[self.view addSubview:_vc.view];
                                             return ;
                                         }
                                         //[SVProgressHUD showError:error];
                                     }];
            return;
        }
        
        
    }
    
    if (self.VcTag == 5) {
        OWTCategoryManagershishang* cm = GetCategoryManagershishang();
        if (!_isFirst) {
            _defalutfeed = [cm.categories firstObject];
            _isFirst = YES;
        }
        [self reloadData];
        
        if (cm.isRefreshNeeded)
        {
            [cm refreshCategoriesWithSuccess:^{
                //            [_refreshControl endPullDownRefreshing];
                _defalutfeed = [cm.categories firstObject];
                _contentType = @"shishang";
                [self reloadData];
            }
                                     failure:^(NSError* error) {
                                         [_refreshControl endPullDownRefreshing];
                                         
                                         //没有网络 并且当前页无缓存数据
                                         if (![NetStatusMonitor isExistenceNetwork] && _categories.count<1) {
                                             
                                             [_vc.view removeFromSuperview];
                                             _vc.getRefreshAction = ^{
                                                 [weakself manualRefresh];
                                             };
                                             
                                             // [self.view addSubview:_vc.view];
                                             return ;
                                         }
                                         [SVProgressHUD showError:error];
                                     }];
            return;
            
        }
        
        
    }
    
    if (self.VcTag == 6){
        
        OWTCategoryManagerbaike* cm = GetCategoryManagerbaike();
        if (!_isFirst) {
            _defalutfeed = [cm.categoriBaike firstObject];
            _isFirst = YES;
        }
        [self reloadData];
        
        if (cm.isRefreshNeeded)
        {
            
            [cm refreshCategoriesBaikeWithSuccess:^{
                //            [_refreshControl endPullDownRefreshing];
                _defalutfeed = [cm.categoriBaike firstObject];
                _contentType = @"baike";
                [self reloadData];
            }
                                          failure:^(NSError* error) {
                                              [_refreshControl endPullDownRefreshing];
                                              
                                              //没有网络 并且当前页无缓存数据
                                              if (![NetStatusMonitor isExistenceNetwork] && _categories.count<1) {
                                                  
                                                  [_vc.view removeFromSuperview];
                                                  _vc.getRefreshAction = ^{
                                                      [weakself manualRefresh];
                                                  };
                                                  
                                                  //[self.view addSubview:_vc.view];
                                                  return ;
                                              }
                                             // [SVProgressHUD showError:error];
                                          }];
            return;
            
        }
        
        
    }
    
    
    if (self.VcTag == 2) {
        OWTCategoryManagerjiaju* cm = GetCategoryManagerjiaju();
        if (!_isFirst) {
            _defalutfeed = [cm.categories firstObject];
            _isFirst = YES;
        }
        [self reloadData];
        
        if (cm.isRefreshNeeded)
        {
            _defalutfeed = [cm.categories firstObject];
            [cm refreshCategoriesWithSuccess:^{
                //            [_refreshControl endPullDownRefreshing];
                _defalutfeed = [cm.categories firstObject];
                _contentType = @"jiaju";
                [self reloadData];
            }
                                     failure:^(NSError* error) {
                                         [_refreshControl endPullDownRefreshing];
                                         //没有网络 并且当前页无缓存数据
                                         if (![NetStatusMonitor isExistenceNetwork] && _categories.count<1) {
                                             
                                             [_vc.view removeFromSuperview];
                                             _vc.getRefreshAction = ^{
                                                 [weakself manualRefresh];
                                             };
                                             
                                             //[self.view addSubview:_vc.view];
                                             return ;
                                         }
                                         //[SVProgressHUD showError:error];
                                     }];
            return;
            
            
        }
        
        
    }
    
    
    if (self.VcTag == 4) {
        OWTCategoryManagermeishi* cm = GetCategoryManagermeishi();
        if (!_isFirst) {
            _defalutfeed = [cm.categories firstObject];
            _isFirst = YES;
        }
        [self reloadData];
        
        if (cm.isRefreshNeeded)
        {
            [cm refreshCategoriesWithSuccess:^{
                //            [_refreshControl endPullDownRefreshing];
                _defalutfeed = [cm.categories firstObject];
                
                _contentType = @"meishi";
                [self reloadData];
                
            }
                                     failure:^(NSError* error) {
                                         //                                     [_refreshControl endPullDownRefreshing];
                                         //没有网络 并且当前页无缓存数据
                                         if (![NetStatusMonitor isExistenceNetwork] && _categories.count<1) {
                                             
                                             [_vc.view removeFromSuperview];
                                             _vc.getRefreshAction = ^{
                                                 [weakself manualRefresh];
                                             };
                                             
                                             //[self.view addSubview:_vc.view];
                                             return ;
                                         }
                                         //[SVProgressHUD showError:error];
                                     }];
            return;
            
        }
        
        
    }
    
    if (self.VcTag == 3) {
        OWTCategoryManagerqiche* cm = GetCategoryManagerqiche();
        if (!_isFirst) {
            _defalutfeed = [cm.categories firstObject];
            _isFirst = YES;
        }
        [self reloadData];
        
        if (cm.isRefreshNeeded){
            [cm refreshCategoriesWithSuccess:^{
                //            [_refreshControl endPullDownRefreshing];
                _defalutfeed = [cm.categories firstObject];
                _contentType = @"qiche";
                [self reloadData];
                
                
            }
                                     failure:^(NSError* error) {
                                         [_refreshControl endPullDownRefreshing];
                                         //没有网络 并且当前页无缓存数据
                                         if (![NetStatusMonitor isExistenceNetwork] && _categories.count<1) {
                                             
                                             [_vc.view removeFromSuperview];
                                             _vc.getRefreshAction = ^{
                                                 [weakself manualRefresh];
                                             };
                                             
                                             //[self.view addSubview:_vc.view];
                                             return ;
                                         }
                                         //[SVProgressHUD showError:error];
                                     }];
            return;
            
        }
        
        
    }
    [self getsubByFeedId];
    
    
}

-(BOOL) navigationShouldPopOnBackButton ///在这个方法里写返回按钮的事件处理
{
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    UIApplication *application = [UIApplication sharedApplication];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBar.barTintColor = GetThemer().homePageColor;
    [self.navigationController popViewControllerAnimated:YES];
    return YES;
}

- (void)reloadData
{
    NSLog(@"self.view.tag %ld",self.view.tag);
    if (self.VcTag == 5) {
        //需要判断是否需要加载
        _categories = GetCategoryManagershishang().categories;
        _contentType = @"shishang";
        
        NSLog(@"nima1");
    }
    if (self.VcTag == 1) {
        _categories = GetCategoryManagerlvyou().categories;
        NSLog(@"nima2");
        _contentType = @"lvyou";
        
        
    }
    if (self.VcTag == 2) {
        _categories = GetCategoryManagerjiaju().categories;
        _contentType = @"jiaju";
        
        NSLog(@"nima2");
        
    }
    if (self.VcTag == 4) {
        _categories = GetCategoryManagermeishi().categories;
        _contentType = @"meishi";
        
        NSLog(@"nima3");
        
    }
    if (self.VcTag == 3) {
        _categories = GetCategoryManagerqiche().categories;
        _contentType = @"qiche";
        
        NSLog(@"nima4");
        
    }
    if (self.VcTag==6) {
        _categories=GetCategoryManagerbaike().categoriBaike;
        _contentType = @"baike";
        
    }
    
    [self setupJCTopic];
    [self getsubByFeedId];
    [_collectionView reloadData];
}

//collecionview的刷新
-(void)getsubByFeedId
{
    _feed = [GetFeedManager() feedForCategoryData:_defalutfeed];
    
    //从缓存中取出 _feed的items ,使用items里面的url 去更新
    [_feed setSubCategoriesCacheData2Items:_defalutfeed.categoryName];
    [_collectionView reloadData];
    
    [self refreshFeed];
}

- (void)refreshFeed
{
    [_collectionView reloadData];
    
    [_feed refreshWithSuccess:^{
        [_vc.view removeFromSuperview];
        [_refreshControl endPullDownRefreshing];
        [_collectionView reloadData];
        
    }
                      failure:^(NSError* error) {
                          [_refreshControl endPullDownRefreshing];
                          [_collectionView reloadData];
                          __weak  OQJFusionViewVC*  weakself = self;
                          //没有网络 并且当前页无缓存数据
                          if (![NetStatusMonitor isExistenceNetwork] && _feed.items.count<1) {
                              
                              [_vc.view removeFromSuperview];
                              _vc.getRefreshAction = ^{
                                  [weakself manualRefresh];
                              };
                              
                              [self.view addSubview:_vc.view];
                              return ;
                          }
                          //[SVProgressHUD showError:error];
                      }];
}


-(void)setUpTopic
{
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, DISTSCROVIEW, SCREENWIT-5, (SCREENWIT-30)/4)];
    //实例化
    _fusionScrollView = [[FusionScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT-5, (SCREENWIT-25)/4)];
    //代理
    _fusionScrollView.JCdelegate = self;
    [view addSubview:_fusionScrollView];
    [self.view addSubview:view];
    //    [_collectionView addSubview:view];
    NSMutableArray * tempArray = [[NSMutableArray alloc]init];
    NSString *homeDictionary = NSHomeDirectory();//获取根目录
    NSString *homePath  = [homeDictionary stringByAppendingString:@"/Documents/atany13.archiver"];//添加储存的文件名
    NSDictionary *cacheData = [NSKeyedUnarchiver unarchiveObjectWithFile:homePath];
    NSDictionary *cacheSubDic = [cacheData objectForKey:_contentType];
    NSArray *cacheArray = [cacheSubDic objectForKey:_contentType];
    _defalutfeed = [cacheArray firstObject];
    if (cacheArray == nil) {
        return;
    }
    
    for (OWTCategoryData *categoryData in cacheArray) {
        
        NSString *str = categoryData.coverImageInfo.url !=nil?categoryData.coverImageInfo.url:@"";
        NSString *categoryName =  categoryData.categoryName!=nil?categoryData.categoryName:@"";
        [tempArray addObject:[NSDictionary dictionaryWithObjects:@[str,categoryName,@NO,categoryData] forKeys:@[@"pic",@"title",@"isLoc",@"category"]]];
        
    }
    
    //加入数据 轮播图URL地址
    _fusionScrollView.pics = tempArray;
    _fusionScrollView.ifHomePage = YES;
    NSLog(@"tempArray: %@",tempArray);
    //更新
    [_fusionScrollView upDate];
}

-(void)setupJCTopic
{
    NSMutableArray * tempArray = [[NSMutableArray alloc]init];
    NSString *homeDictionary = NSHomeDirectory();//获取根目录
    NSString *homePath  = [homeDictionary stringByAppendingString:@"/Documents/atany13.archiver"];
    if (_categories.count <1) {
        return;
    }
    NSDictionary *cacheDataDic = [NSKeyedUnarchiver unarchiveObjectWithFile:homePath];
    if (cacheDataDic == nil) {
        cacheDataDic = [[NSDictionary alloc]init];
    }
    NSMutableDictionary *multilDic = [[NSMutableDictionary alloc]initWithDictionary:cacheDataDic];
    
    NSDictionary *subType = [NSDictionary dictionaryWithObject:_categories forKey:_contentType ];
    
    [multilDic setObject:subType forKey:_contentType];
    [NSKeyedArchiver archiveRootObject:multilDic toFile:homePath];
    for (OWTCategoryData *categoryData in _categories) {
        
        NSString *str = categoryData.coverImageInfo.url !=nil?categoryData.coverImageInfo.url:@"";
        NSString *categoryName =  categoryData.categoryName!=nil?categoryData.categoryName:@"";
        [tempArray addObject:[NSDictionary dictionaryWithObjects:@[str,categoryName,@NO,categoryData] forKeys:@[@"pic",@"title",@"isLoc",@"category"]]];
        
    }
    
    //加入数据 轮播图URL地址
    _fusionScrollView.pics = tempArray;
    _fusionScrollView.ifHomePage = YES;
    NSLog(@"tempArray: %@",tempArray);
    //更新
    [_fusionScrollView upDate];
}

#pragma -fusionScroviwDelegate
-(void)currentPage:(int)page total:(NSUInteger)total{
    
}

#pragma -fusionScroviwDelegate
-(void)mdidClick:(id)data withImageView:(UIImageView*)imageV{
    NSDictionary *dic = (NSDictionary*)data;
    _currentTrigle = [dic objectForKey:@"dic"];
    _defalutfeed = [dic objectForKey:@"category"];
    _defalutfeed = [dic objectForKey:@"category"];
    [imageV addSubview:_effectView];
    [self manualRefresh];
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
    if (_feed != nil)
    {
        return _feed.items.count;
    }
    else
    {
        return 30;
    }
    
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
            cell.imageView.placeholderImage = [UIImage imageNamed:@"_0003_矢量智能对象"];
            cell.backgroundColor = [UIColor lightGrayColor];
            //            UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 100, 50)];
            //            lable.backgroundColor = [UIColor redColor];
            //            [cell addSubview:lable];
            //            [cell setImageWithImage:[UIImage imageNamed:@"_0003_矢量智能对象"]];
            //            cell.frame = CGRectMake(10, 20, 100, 100);
            //            cell.backgroundColor = [UIColor redColor];
            
        }
    }
    
    return cell;
}

- (UIImage*) createImageWithColor: (UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
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

#pragma mark - Asset Displaying

- (void)displayAsset:(OWTAsset*)asset
{
    OWTAssetViewCon* assetViewCon = [[OWTAssetViewCon alloc] initWithAsset:asset deletionAllowed:YES onDeleteAction:^{ [self reloadData]; }];
    [self.navigationController pushViewController:assetViewCon animated:YES];
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

- (void)search
{
    OWTSearchViewCon* searchViewCon = [[OWTSearchViewCon alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:searchViewCon animated:YES];
}



@end
