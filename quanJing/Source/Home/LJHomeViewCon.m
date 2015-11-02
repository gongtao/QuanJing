//
//  LJHomeViewCon.m
//  Weitu
//
//  Created by qj-app on 15/8/13.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJHomeViewCon.h"
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
#import "JCTopic.h"
#import "OWTSearchResultsViewCon.h"
#import "UIImageView+AFNetworking.h"
#import "UIColor+HexString.h"
#import "OQJExploreViewCon1.h"
#import "LJHomeVIewCellTableViewCell.h"
#import "MJRefresh.h"
#import "LJSelectedViewCon.h"
#import "OWTUserSharedAssetsViewCon.h"
#import "OWTAuthManager.h"
#import "REMenu.h"
#import "FAKFontAwesome.h"
#import "LJCollectionViewController.h"
#import "OWTSMSInviteViewCon.h"
#import "OQJSelectedViewCon2.h"
#import "ASIHTTPRequest.h"
#import "LJClassViewCon.h"
#import "WLJWebViewController.h"
#import "LJSearchViewController.h"
#import "OQJFusionViewVC.h"
#import "RESideMenuItem.h"
#import "RESideMenu.h"
#import "OWTUserViewCon.h"
#import "OQJSearchPageVC.h"
#import "QuanJingSDK.h"
#import <UIImageView+WebCache.h>
#import "OWTAppDelegate.h"
#define IS_WIDESCREEN (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) < DBL_EPSILON)
@interface LJHomeViewCon () <JCTopicDelegate, UISearchBarDelegate>
@property (nonatomic, strong) JCTopic * Topic;
@property (strong, nonatomic)  UIPageControl * page;
@end

#define DISTSCROVIEW	45
#define lvyou			0
#define jiaju			1
#define qiche			2
#define meishi			3
#define shishang		4
#define baike			5

@implementation LJHomeViewCon
{
	UITableView * _tableView;
	NSMutableArray * _showArr;
	MBProgressHUD * _progress;
	UIView * _view;
	UISearchBar * _searchBar;
	UITapGestureRecognizer * _tap;
	NSMutableArray * _categaryBeautiful;
	OWTTabBarHider * _tabBarHider;
	REMenu * _feedMenu;
	NSMutableArray * _customViews;
	NSURLConnection * _connection;
	NSURLConnection * _connection1;
	NSMutableArray * _biaoqianClickArr;
	RESideMenu * _sideMenu;
	OWTUserViewCon * _userViewCon1;
	NSString * _keyword;
    UIImageView *adverBack;
    UIImageView *advertisetion;
    NSMutableData *_data;
    UIWindow *_window;
}
- (void)viewWillAppear:(BOOL)animated
{
	[_tabBarHider showTabBar];
	[self.view setHidden:NO];
	
	//    [self setupNavigationBarColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[_searchBar resignFirstResponder];
	_searchBar.text = nil;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
	[self setUpNavigation];
	[self setUpData];
	[self setUpTableView];
	[self setUpOtherView];
	[self setUpHeaderView];
	[self setupNavMenu];
    [self setUpAdversation];
}
-(void)setUpAdversation
{
    _window=[[UIWindow alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, SCREENHEI)];
    _window.windowLevel = UIWindowLevelStatusBar + 1;
    [_window makeKeyAndVisible];
    adverBack=[LJUIController createImageViewWithFrame:CGRectMake(0, 0, SCREENWIT, SCREENHEI) imageName:@"开机画面6s.png"];
    //    imageView.backgroundColor=[UIColor whiteColor];
    [_window addSubview:adverBack];
    advertisetion=[LJUIController createImageViewWithFrame:CGRectMake(0, 0, SCREENWIT, SCREENHEI-120) imageName:@""];
    //    advertisetion.backgroundColor=[UIColor whiteColor];
    [adverBack addSubview:advertisetion];
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *imgUrl=[userDefaults objectForKey:@"ImgUrl"];
    if (imgUrl!=nil) {
        [advertisetion setImageWithURL:[NSURL URLWithString:imgUrl]];
    }
    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://api.tiankong.com/qjapi/homead"]] delegate:self];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [_data setLength:0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
[UIView animateWithDuration:03 animations:^{
    adverBack.alpha=0.0;
}];
    [self removeAdvertise];
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSArray *arr=[NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableContainers error:nil];
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *dict=arr[0];
    NSString *str=[userDefaults objectForKey:@"id"];
    NSString *imgUrl=[userDefaults objectForKey:@"ImgUrl"];
    if ([dict[@"id"] isEqualToString:@"0"]) {
        
        [userDefaults removeObjectForKey:@"ImgUrl"];
        //        [userDefaults removeObjectForKey:@"id"];
        [userDefaults synchronize];
        [self removeAdvertise];
    }else {
        if (imgUrl!=nil) {
            [advertisetion setImageWithURL:[NSURL URLWithString:dict[@"ImgUrl"]]];
        }
        [self performSelector:@selector(removeAdvertise) withObject:nil afterDelay:3];
        if (![str isEqualToString:dict[@"id"]]) {
            [userDefaults setValue:dict[@"id"] forKey:@"id"];
            [userDefaults setValue:dict[@"ImgUrl"] forKey:@"ImgUrl"];
        }}
}
-(void)removeAdvertise
{
    [UIView animateWithDuration:0.3 animations:^{
        _window.alpha=0;
    } completion:^(BOOL finished) {
       [_window removeFromSuperview];
    }];
}
- (void)setUpData
{
	_keyword = [[NSString alloc]init];
	_tabBarHider = [[OWTTabBarHider alloc]init];
	_showArr = [[NSMutableArray alloc]init];
	_categaryBeautiful = [[NSMutableArray alloc]init];
	_biaoqianClickArr = [[NSMutableArray alloc]init];
    _data=[[NSMutableData alloc]init];
	[self getThePreserveData];
}

- (void)getThePreserveData
{
	NSString * homeDictionary = NSHomeDirectory();	// 获取根目录
	NSString * homePath = [homeDictionary stringByAppendingString:@"/Documents/homeIndex.archiver"];
	NSDictionary * homeIndexDic = [NSKeyedUnarchiver unarchiveObjectWithFile:homePath];
	
	if (homeIndexDic != nil) {
		[_categaryBeautiful removeAllObjects];
		[_biaoqianClickArr removeAllObjects];
		[_showArr removeAllObjects];
		[_categaryBeautiful addObjectsFromArray:homeIndexDic[@"mhrs"]];
		[_biaoqianClickArr addObjectsFromArray:homeIndexDic[@"shzm"]];
		[_showArr addObjectsFromArray:homeIndexDic[@"lbt"]];
	}
}

#pragma mark setUpAllView
- (void)setUpNavigation
{
	self.title = @"全景";
	NSDictionary * dict = [NSDictionary dictionaryWithObject:[UIColor colorWithHexString:@"f6f6f6"] forKey:UITextAttributeTextColor];
	self.navigationController.navigationBar.titleTextAttributes = dict;
	
	UIButton * left = [LJUIController createButtonWithFrame:CGRectMake(0, 0, 15, 15) imageName:@"选项.png" title:nil target:self action:@selector(showHomeMenu)];
	UIBarButtonItem * btn1 = [[UIBarButtonItem alloc]initWithCustomView:left];
	self.navigationItem.leftBarButtonItem = btn1;
	
	UIButton * right = [LJUIController createButtonWithFrame:CGRectMake(0, 0, 18, 18) imageName:@"收藏.png" title:nil target:self action:@selector(followingClick)];
	UIBarButtonItem * btn2 = [[UIBarButtonItem alloc]initWithCustomView:right];
	self.navigationItem.rightBarButtonItem = btn2;
}

- (void)showHomeMenu
{
	OWTAuthManager * am = GetAuthManager();
	
	if (!am.isAuthenticated) {
		[self showAuthViewCon];
	}
	else {
		if (!_sideMenu) {
			RESideMenuItem * message = [[RESideMenuItem alloc] initWithTitle:@"喜欢的图片" image:[UIImage imageNamed:@"_0001_矢量智能对象-拷贝-3"] highlightedImage:[UIImage imageNamed:@"_0001_矢量智能对象-拷贝-3"] action:^(RESideMenu * menu, RESideMenuItem * item) {
				[menu hide];
				[self presentHomeFeed];
			}];
			RESideMenuItem * activityItem = [[RESideMenuItem alloc] initWithTitle:@"评论的图片" image:[UIImage imageNamed:@"_0000_矢量智能对象2"] highlightedImage:[UIImage imageNamed:@"_0000_矢量智能对象2"] action:^(RESideMenu * menu, RESideMenuItem * item) {
				[menu hide];
				[self presentLatestFeed];
			}];
			RESideMenuItem * fans = [[RESideMenuItem alloc] initWithTitle:@"我的圈子" image:[UIImage imageNamed:@"_0000_矢量智能对象"] highlightedImage:[UIImage imageNamed:@"_0000_矢量智能对象象"] action:^(RESideMenu * menu, RESideMenuItem * item) {
				[menu hide];
				[self presentSquare];
				
				NSLog(@"Item %@", item);
			}];
			RESideMenuItem * invitePee = [[RESideMenuItem alloc] initWithTitle:@"邀请好友" image:[UIImage imageNamed:@"_0005_矢量智能对象"] highlightedImage:[UIImage imageNamed:@"_0005_矢量智能对象"] action:^(RESideMenu * menu, RESideMenuItem * item) {
				[menu hide];
				[self presentSMSInvite];
				
				NSLog(@"Item %@", item);
			}];
			
			_sideMenu = [[RESideMenu alloc] initWithItems:@[message, activityItem, fans, invitePee]];
			_sideMenu.verticalOffset = IS_WIDESCREEN ? 250 : 76;
			
			UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapProfileImage:)];
			[_sideMenu.profileView addGestureRecognizer:tap];
			
			// _sideMenu.hideStatusBarArea = [self OSVersion] < 7;
		}
		
		[_sideMenu show];
	}
}

- (void)onTapProfileImage:(UIGestureRecognizer *)sender
{
	[_sideMenu hide];
	OWTUser * userme = GetUserManager().currentUser;
	
	if (userme != nil) {
		if (_userViewCon1) {
			[_userViewCon1 adealloc];
			_userViewCon1 = nil;
		}
		_userViewCon1 = [[OWTUserViewCon alloc] initWithNibName:nil bundle:nil];
		_userViewCon1.hidesBottomBarWhenPushed = YES;
		_userViewCon1.ifFirstEnter = YES;
		_userViewCon1.rightTriggle = YES;
		__weak __typeof( & * self) weakSelf = self;
		
		[weakSelf.navigationController pushViewController:_userViewCon1 animated:YES];
		_userViewCon1.user = userme;
	}
}

- (void)setUpTableView
{
	_tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, SCREENHEI - 64 - 5) style:UITableViewStyleGrouped];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];
	[_tableView addHeaderWithTarget:self action:@selector(getAllData) dateKey:@"table"];
	[_tableView headerBeginRefreshing];
	
	// 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
	//    [_tableView addFooterWithTarget:self action:@selector(loadMoreFeedItems)];
	// 一些设置
	// 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
	_tableView.headerPullToRefreshText = @"";
	_tableView.headerReleaseToRefreshText = @"";
	_tableView.headerRefreshingText = @"";
	
	_tableView.footerPullToRefreshText = @"";
	_tableView.footerReleaseToRefreshText = @"";
	_tableView.footerRefreshingText = @"";
}

- (void)setUpHeaderView
{
	CGFloat imageWit = (SCREENWIT - 30) / 3;
	
	_view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, 312 + imageWit * 2)];
	_page = [[UIPageControl alloc] initWithFrame:CGRectMake(140, 150, 40, 5 + 8)];
	_page.currentPage = 0;	// 指定pagecontroll的值，默认选中的小白点（第一个）
	_page.currentPageIndicatorTintColor = [UIColor blueColor];
	_page.backgroundColor = [UIColor blackColor];
	_page.hidden = YES;
	_view.backgroundColor = [UIColor whiteColor];
	[self setUpTopic];
	[_Topic addSubview:_page];
	[_view addSubview:_Topic];
	//    [self SetUpsearchView];
	UIImageView * searchView = [LJUIController createImageViewWithFrame:CGRectMake(10, 190, 235, 32.5) imageName:@"搜索"];
	//    searchView.backgroundColor=[UIColor blackColor];
	[_view addSubview:searchView];
	UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onSearchTap)];
	[searchView addGestureRecognizer:tap];
	UIImageView * classify = [LJUIController createImageViewWithFrame:CGRectMake(250, 190, 60, 32.5) imageName:@"分类"];
	[_view addSubview:classify];
	UITapGestureRecognizer * classTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(classTapy)];
	[classify addGestureRecognizer:classTap];
	// UILabel *capLabel=[LJUIController createLabelWithFrame:CGRectMake(10, 230, 200, 20) Font:15 Text:@"读图时代 美好人生"];
	//    capLabel.font=[UIFont fontWithName:@"冬青黑体" size:12];
	// [_view addSubview:capLabel];
	NSArray * arr = @[@"旅游", @"家居", @"汽车", @"美食", @"时尚", @"艺术"];
	
	for (NSInteger i = 0; i < 6; i++) {
		UIImageView * imageView;
		
		UILabel * label;
		QJHomeIndexObject * model;
		
		if (_categaryBeautiful.count > 0)
			model = _categaryBeautiful[i];
		NSString * imageUrl = [QJInterfaceManager thumbnailUrlFromImageUrl:model.imageUrl size:CGSizeMake(imageWit, imageWit - 2)];
		
		if (i < 3) {
			imageView = [LJUIController createImageViewWithFrame:CGRectMake(10 + i % 3 * (imageWit + 5), 230, imageWit, imageWit - 2) imageName:nil];
			label = [LJUIController createLabelWithFrame:CGRectMake(0, 0, 40, 20) Font:14 Text:(model.title == nil ? arr[i] : model.title)];
			label.center = CGPointMake(10 + i % 3 * (imageWit + 5) + imageWit / 2, 260 + imageWit + 15 - 30 - 5 - 2);
		}
		else {
			imageView = [LJUIController createImageViewWithFrame:CGRectMake(6 + i % 3 * (imageWit + 6), 230 + imageWit + 35 - 10 - 3 - 2, imageWit, imageWit - 2) imageName:nil];
			label = [LJUIController createLabelWithFrame:CGRectMake(0, 0, 40, 20) Font:14 Text:(model.title == nil ? arr[i] : model.title)];
			label.center = CGPointMake(10 + i % 3 * (imageWit + 5) + imageWit / 2, 260 + imageWit * 2 + 35 + 15 - 30 - 10 - 3 - 4 - 2);
		}
		imageView.tag = i + 100;
		UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
		[imageView addGestureRecognizer:tap];
		[_view addSubview:imageView];
		[_view addSubview:label];
		
		imageView.alpha = 0.0;
		__weak UIImageView * weakImageView = imageView;
		[imageView setImageWithURL:[NSURL URLWithString:imageUrl]
		placeholderImage:nil
		completed:^(UIImage * image, NSError * error, SDImageCacheType cacheType) {
			if (cacheType == SDImageCacheTypeNone) {
				[UIView animateWithDuration:0.3
				animations:^{
					weakImageView.alpha = 1.0;
				}];
				return;
			}
			weakImageView.alpha = 1.0;
		}];
	}
	
	UIImageView * grayImage = [LJUIController createImageViewWithFrame:CGRectMake(0, 260 + imageWit * 2 + 70 - 30 - 10 - 3 - 4 - 2, SCREENWIT, 10) imageName:nil];
	grayImage.backgroundColor = [UIColor colorWithHexString:@"#f6f6f6"];
	[_view addSubview:grayImage];
	UILabel * capLabel1 = [LJUIController createLabelWithFrame:CGRectMake(10, 330 + 20 + imageWit * 2 - 30 - 10 - 3 - 4 - 2, 200, 20) Font:15 Text:@"热门标签"];
	[_view addSubview:capLabel1];
}

- (void)reloadImageViewImage
{
	for (UIView * view in _view.subviews)
		for (NSInteger i = 0; i < 6; i++) {
			QJHomeIndexObject * model;
			
			if (_categaryBeautiful.count > 0)
				model = _categaryBeautiful[i];
				
			if (view.tag == i + 100) {
				UIImageView * imageView = (UIImageView *)view;
				NSString * imageUrl = [QJInterfaceManager thumbnailUrlFromImageUrl:model.imageUrl size:CGSizeMake((SCREENWIT - 30) / 3, (SCREENWIT - 30) / 3 - 2)];
				imageView.alpha = 0.0;
				__weak UIImageView * weakImageView = imageView;
				[imageView setImageWithURL:[NSURL URLWithString:imageUrl]
				placeholderImage:nil
				completed:^(UIImage * image, NSError * error, SDImageCacheType cacheType) {
					if (cacheType == SDImageCacheTypeNone) {
						[UIView animateWithDuration:0.3
						animations:^{
							weakImageView.alpha = 1.0;
						}];
						return;
					}
					weakImageView.alpha = 1.0;
				}];
			}
		}
}

- (void)setUpOtherView
{
	_progress = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:_progress];
	//    [_progress show:YES];
	self.view.backgroundColor = [UIColor colorWithHexString:@"ededed"];
	_tableView.backgroundColor = [UIColor colorWithHexString:@"ededed"];
}

- (void)setUpTopic
{
	_Topic = [[JCTopic alloc]initWithFrame:CGRectMake(0, 0, 320, 180)];
	// 代理
	_Topic.JCdelegate = self;
	_Topic.progress = _progress;
	_Topic.page = _page;
	
	// 加入数据 轮播图URL地址
	if (_showArr.count > 0) {
		NSMutableArray * tempArray = [[NSMutableArray alloc]init];
		[_showArr enumerateObjectsUsingBlock:^(QJHomeIndexObject * obj, NSUInteger idx, BOOL * _Nonnull stop) {
			NSString * str = obj.imageUrl;
			NSString * str1 = obj.title;
			[tempArray addObject:[NSDictionary dictionaryWithObjects:@[str, str1, @NO] forKeys:@[@"pic", @"title", @"isLoc"]]];
		}];
		_Topic.pics = tempArray;
		_Topic.ifHomePage = YES;
		
		[_Topic upDate];
		_page.numberOfPages = tempArray.count;	// 指定页面个数
	}
}

- (void)SetUpsearchView
{
	// self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:23/255.0f green:200/255.0f  blue:184/255.0f alpha:1.0f];
	_searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 152, SCREENWIT - 50, 40)];
	_searchBar.delegate = self;
	_searchBar.placeholder = @"搜图片";
	_searchBar.userInteractionEnabled = YES;
	//    _searchBar.translucent = NO;
	_searchBar.searchBarStyle = UISearchBarStyleMinimal;
	[_searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"SearchBarBG"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)]
	forState:UIControlStateNormal];
	[_searchBar.layer setBorderColor:[UIColor redColor].CGColor];
	UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onSearchTap)];
	[_searchBar addGestureRecognizer:tap];
}

- (void)changeSearchBarBackcolor:(UISearchBar *)mySearchBar
{
	float version = [[[UIDevice currentDevice] systemVersion] floatValue];
	
	if ([mySearchBar respondsToSelector:@selector(barTintColor)]) {
		float iosversion7_1 = 7.1;
		
		if (version >= iosversion7_1) {
			[[[[mySearchBar.subviews objectAtIndex:0] subviews] objectAtIndex:0] removeFromSuperview];
			[mySearchBar setBackgroundColor:[UIColor clearColor]];
			//            [ mySearchBar setBackgroundColor :[ UIColor colorWithHexString:@"#f0f1f3"]];
		}
		else {
			[mySearchBar setBarTintColor:[UIColor clearColor]];
			//            [mySearchBar setBackgroundColor:[UIColor clearColor]];
			//            [ mySearchBar setBackgroundColor :[ UIColor colorWithHexString:@"#f0f1f3"]];
		}
	}
	else {
		[[mySearchBar.subviews objectAtIndex:0] removeFromSuperview];
		[mySearchBar setBackgroundColor:[UIColor clearColor]];
		//        [ mySearchBar setBackgroundColor :[ UIColor colorWithHexString:@"#f0f1f3"]];
	}
	
	[_searchBar.layer setBorderColor:[UIColor redColor].CGColor];
}

- (void)setupNavMenu
{
	_customViews = [[NSMutableArray alloc]init];
	NSArray * title = @[@"喜欢的图片", @"评论的图片", @"我的圈子", @"邀请好友"];
	NSArray * images = @[@"icon_list_like.png", @"icon_list_common.png", @"icon_list_myCircle.png", @"icon_list_addfriend.png"];
	
	for (NSInteger i = 0; i < 4; i++) {
		UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, 40)];
		view.backgroundColor = [UIColor whiteColor];
		UIImageView * imageView;
		
		if (i < 2)
			imageView = [LJUIController createImageViewWithFrame:CGRectMake(30, 12.5, 15, 15) imageName:images[i]];
		else
			imageView = [LJUIController createImageViewWithFrame:CGRectMake(27.5, 12.5, 20, 15) imageName:images[i]]; [view addSubview:imageView];
		UILabel * label = [LJUIController createLabelWithFrame:CGRectMake(70, 12.5, 100, 15) Font:12 Text:title[i]];
		[view addSubview:label];
		UIImageView * imageVIEW1 = [LJUIController createImageViewWithFrame:CGRectMake(SCREENWIT - 30, 12.5, 10, 15) imageName:@"首页18-1_05.png"];
		[view addSubview:imageVIEW1];
		[_customViews addObject:view];
	}
	
	REMenuItem * _homeItem = [[REMenuItem alloc]initWithCustomView:_customViews[0] action:^(REMenuItem * item) {
		[self presentHomeFeed];
	}];
	
	REMenuItem * latestItem = [[REMenuItem alloc]initWithCustomView:_customViews[1] action:^(REMenuItem * item) {
		[self presentLatestFeed];
	}];
	REMenuItem * wallpaperItem = [[REMenuItem alloc]initWithCustomView:_customViews[2] action:^(REMenuItem * item) {
		[self presentSquare];
	}];
	REMenuItem * followingItem = [[REMenuItem alloc]initWithCustomView:_customViews[3] action:^(REMenuItem * item) {
		[self presentSMSInvite];
	}];
	_feedMenu = [[REMenu alloc] initWithItems:@[_homeItem, latestItem, wallpaperItem, followingItem]];
	_feedMenu.liveBlur = YES;
	_feedMenu.liveBlurBackgroundStyle = REMenuLiveBackgroundStyleLight;
	_feedMenu.closeOnSelection = YES;
	_feedMenu.itemHeight = 40;
	_feedMenu.font = [UIFont boldSystemFontOfSize:16];
	_feedMenu.textOffset = CGSizeMake(0, 2);
	_feedMenu.textColor = [UIColor darkGrayColor];
	_feedMenu.subtitleFont = [UIFont systemFontOfSize:13];
	_feedMenu.subtitleTextColor = [UIColor darkGrayColor];
	_feedMenu.subtitleTextOffset = CGSizeMake(0, -1);
	_feedMenu.subtitleTextShadowColor = nil;
	_feedMenu.borderWidth = 0.5;
	_feedMenu.borderColor = [UIColor lightGrayColor];
	_feedMenu.separatorColor = [UIColor lightGrayColor];
	_feedMenu.separatorHeight = 0.5;
	
	_feedMenu.highlightedTextShadowColor = nil;
	_feedMenu.highlightedTextColor = [UIColor blackColor];
	_feedMenu.subtitleHighlightedTextColor = [UIColor blackColor];
	_feedMenu.subtitleHighlightedTextShadowColor = nil;
	_feedMenu.highlightedBackgroundColor = GetThemer().themeColor;
	
	_feedMenu.cornerRadius = 4;
	
	_feedMenu.imageOffset = CGSizeMake(10, 0);
	_feedMenu.waitUntilAnimationIsComplete = NO;
	
	__weak typeof(* self) * weakSelf = self;
	
	_feedMenu.closeCompletionHandler = ^{
		weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
	};
}

#pragma mark searchDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	//    [searchBar endEditing:YES];
	LJSearchViewController * lvc = [[LJSearchViewController alloc]init];
	
	lvc.hidesBottomBarWhenPushed = YES;
	[_tabBarHider hideTabBar];
	[self.navigationController pushViewController:lvc animated:NO];
}

- (void)performSearch
{
	OWTSearchResultsViewCon * searchResultsViewCon = [[OWTSearchResultsViewCon alloc] initWithNibName:nil bundle:nil];
	
	searchResultsViewCon.view.tag = 8173;
	[searchResultsViewCon setKeyword:_keyword];
	searchResultsViewCon.hidesBottomBarWhenPushed = YES;
	//	[searchResultsViewCon substituteNavigationBarBackItem];
	[_tabBarHider hideTabBar];
	[self.navigationController pushViewController:searchResultsViewCon animated:YES];
	_searchBar.text = nil;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar					// called when
{
	[self performSearch];
	[_searchBar resignFirstResponder];
	_searchBar.text = @"";
}

#pragma mark getData
- (void)getAllData
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		QJInterfaceManager * fm = [QJInterfaceManager sharedManager];
		[fm requestHomeIndex:^(NSDictionary * _Nonnull homeIndexDic, NSArray * _Nonnull resultArray, NSError * _Nonnull error) {
			if (error != nil)
				return;
				
			NSString * homeDictionary = NSHomeDirectory();	// 获取根目录
			NSString * homePath = [homeDictionary stringByAppendingString:@"/Documents/homeIndex.archiver"];
			BOOL ret = [NSKeyedArchiver archiveRootObject:homeIndexDic toFile:homePath];
			[_categaryBeautiful removeAllObjects];
			[_biaoqianClickArr removeAllObjects];
			[_showArr removeAllObjects];
			[_categaryBeautiful addObjectsFromArray:homeIndexDic[@"mhrs"]];
			[_biaoqianClickArr addObjectsFromArray:homeIndexDic[@"shzm"]];
			[_showArr addObjectsFromArray:homeIndexDic[@"lbt"]];
			NSMutableArray * tempArray = [[NSMutableArray alloc]init];
			[_showArr enumerateObjectsUsingBlock:^(QJHomeIndexObject * obj, NSUInteger idx, BOOL * _Nonnull stop) {
				NSString * str = obj.imageUrl;
				NSString * str1 = obj.title;
				[tempArray addObject:[NSDictionary dictionaryWithObjects:@[str, str1, @NO] forKeys:@[@"pic", @"title", @"isLoc"]]];
			}];
			_Topic.pics = tempArray;
			_Topic.ifHomePage = YES;
			_page.numberOfPages = tempArray.count;
			dispatch_async(dispatch_get_main_queue(), ^{
				[_Topic upDate];
				[self reloadImageViewImage];
				[_tableView reloadData];
				[_tableView headerEndRefreshing];
			});
		}];
	});
}

#pragma mark tapAndButton
- (void)onSearchTap
{
	LJSearchViewController * lvc = [[LJSearchViewController alloc]init];
	
	lvc.hidesBottomBarWhenPushed = YES;
	[_tabBarHider hideTabBar];
	[self.navigationController pushViewController:lvc animated:NO];
}

- (void)classTapy
{
	LJClassViewCon * lvc = [[LJClassViewCon alloc]init];
	
	lvc.hidesBottomBarWhenPushed = YES;
	[_tabBarHider hideTabBar];
	[self.navigationController pushViewController:lvc animated:YES];
}

- (void)cehuaClick
{
	if (_feedMenu.isOpen)
		return [_feedMenu close];
		
	self.navigationItem.rightBarButtonItem.enabled = NO;
	[_feedMenu showFromNavigationController:self.navigationController];
}

- (void)followingClick
{
	OWTAuthManager * am = GetAuthManager();
	
	if (!am.isAuthenticated) {
		[self showAuthViewCon];
	}
	else {
		OWTUserSharedAssetsViewCon * likedAssetsViewCon = [[OWTUserSharedAssetsViewCon alloc] initWithNibName:nil bundle:nil];
		likedAssetsViewCon.user1 = [[QJPassport sharedPassport]currentUser];
		likedAssetsViewCon.lightbox = [likedAssetsViewCon.user1.collectAmount intValue];
		[_tabBarHider hideTabBar];
		[self.navigationController pushViewController:likedAssetsViewCon animated:YES];
	}
}

- (void)tapImage:(UIGestureRecognizer *)sender
{
	[_tabBarHider hideTabBar];
	[self.view setHidden:YES];
	NSInteger selectTag = sender.view.tag - 100;
	
	if (!_categaryBeautiful || (selectTag >= _categaryBeautiful.count))
		return;
		
	QJHomeIndexObject * model = _categaryBeautiful[selectTag];
	BOOL isSearch = [model.type isEqualToString:@"search"];
	
	// 旅游的跳转页面
	if (selectTag == lvyou) {
		if (isSearch) {
			OQJSearchPageVC * jumpserach = [[OQJSearchPageVC alloc]initWithSeachContent:model.title];
			jumpserach.hidesBottomBarWhenPushed = YES;
			[self.navigationController pushViewController:jumpserach animated:NO];
			return;
		}
		OQJFusionViewVC * hottestViewCon = [[OQJFusionViewVC alloc] init];
		hottestViewCon.VcTag = lvyou;
		hottestViewCon.contentType = @"lvyou";
		[self.navigationController pushViewController:hottestViewCon animated:NO];
		return;
	}
	
	if (selectTag == jiaju) {
		if (isSearch) {
			OQJSearchPageVC * jumpserach = [[OQJSearchPageVC alloc]initWithSeachContent:model.title];
			jumpserach.hidesBottomBarWhenPushed = YES;
			[self.navigationController pushViewController:jumpserach animated:NO];
			return;
		}
		OQJFusionViewVC * hottestViewCon = [[OQJFusionViewVC alloc] init];
		hottestViewCon.VcTag = 2;
		hottestViewCon.contentType = @"jiaju";
		
		[self.navigationController pushViewController:hottestViewCon animated:YES];
		return;
	}
	
	if (selectTag == qiche) {
		if (isSearch) {
			OQJSearchPageVC * jumpserach = [[OQJSearchPageVC alloc]initWithSeachContent:model.title];
			jumpserach.hidesBottomBarWhenPushed = YES;
			
			[self.navigationController pushViewController:jumpserach animated:NO];
			return;
		}
		OQJFusionViewVC * hottestViewCon = [[OQJFusionViewVC alloc] init];
		hottestViewCon.VcTag = 3;
		hottestViewCon.contentType = @"qiche";
		
		[self.navigationController pushViewController:hottestViewCon animated:YES];
		return;
	}
	
	if (selectTag == meishi) {
		if (isSearch) {
			OQJSearchPageVC * jumpserach = [[OQJSearchPageVC alloc]initWithSeachContent:model.title];
			jumpserach.hidesBottomBarWhenPushed = YES;
			[self.navigationController pushViewController:jumpserach animated:NO];
			return;
		}
		OQJFusionViewVC * hottestViewCon = [[OQJFusionViewVC alloc] init];
		hottestViewCon.VcTag = 4;
		hottestViewCon.contentType = @"meishi";
		
		[self.navigationController pushViewController:hottestViewCon animated:YES];
		return;
	}
	
	if (selectTag == shishang) {
		if (isSearch) {
			OQJSearchPageVC * jumpserach = [[OQJSearchPageVC alloc]initWithSeachContent:model.title];
			jumpserach.hidesBottomBarWhenPushed = YES;
			[self.navigationController pushViewController:jumpserach animated:NO];
			return;
		}
		OQJFusionViewVC * hottestViewCon = [[OQJFusionViewVC alloc] init];
		hottestViewCon.VcTag = 5;
		hottestViewCon.contentType = @"shishang";
		
		[self.navigationController pushViewController:hottestViewCon animated:YES];
		return;
	}
	
	if (selectTag == baike) {
		if (isSearch) {
			OQJSearchPageVC * jumpserach = [[OQJSearchPageVC alloc]initWithSeachContent:model.title];
			jumpserach.hidesBottomBarWhenPushed = YES;
			[self.navigationController pushViewController:jumpserach animated:NO];
			return;
		}
		OQJFusionViewVC * hottestViewCon = [[OQJFusionViewVC alloc] init];
		hottestViewCon.VcTag = 6;
		hottestViewCon.contentType = @"baike";
		
		[self.navigationController pushViewController:hottestViewCon animated:YES];
		return;
	}
}

#pragma mark JCTopicDelegate
- (void)currentPage:(int)page total:(NSUInteger)total
{
	// _label1.text = [NSString stringWithFormat:@"图片 Page %d",page+1];
	_page.numberOfPages = total;
	_page.currentPage = page;
}

- (void)didClick:(id)data
{
	if (_showArr.count == 0)
		return;
		
	[_tabBarHider hideTabBar];
	QJHomeIndexObject * model = _showArr[self.page.currentPage];
	WLJWebViewController * evc = [[WLJWebViewController alloc]init];
	
	//
	evc.SummaryStr = model.detailText;
	//    //
	evc.titleS = model.title;
	evc.urlString = model.typeValue;
	evc.assetUrl = model.imageUrl;
	[self.navigationController pushViewController:evc animated:YES];
	//	[evc substituteNavigationBarBackItem];
}

#pragma mark tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _biaoqianClickArr.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	return _view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	CGFloat imageWit = (SCREENWIT - 30) / 3;
	
	return 380 + imageWit * 2 - 30 - 10 - 3 - 4 - 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString * identifier = @"LJHomeViewCell";
	LJHomeVIewCellTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (!cell)
		cell = [[LJHomeVIewCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	QJHomeIndexObject * model = _biaoqianClickArr[indexPath.row];
	float x = 356;
	float y = 640;
	CGFloat height = x / y * SCREENWIT;
	NSString * imageUrl = [QJInterfaceManager thumbnailUrlFromImageUrl:model.imageUrl size:CGSizeMake(SCREENWIT, height)];
	[cell setImageWithUrl:imageUrl];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	float x = 356;
	float y = 640;
	CGFloat height = x / y * SCREENWIT;
	
	if (indexPath.row == _biaoqianClickArr.count - 1)
		return height;
		
	return height + 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_biaoqianClickArr.count == 0)
		return;
		
	[_tabBarHider hideTabBar];
	QJHomeIndexObject * model = _biaoqianClickArr[indexPath.row];
	NSDictionary * jdic = _biaoqianClickArr[indexPath.row];
	NSString * Type = model.type;
	NSString * searchValue = model.typeValue;
	NSLog(@"searchValue  %@", searchValue);
	
	if ([Type isEqualToString:@"search"]) {
		_keyword = searchValue;
		[self performSearch];
	}
	else if ([Type isEqualToString:@"article"]) {
		if ([searchValue isEqualToString:@"1"]) {
			OQJExploreViewCon1 * evc = [[OQJExploreViewCon1 alloc]init];
			evc.classCount = 1;
			evc.hidesBottomBarWhenPushed = YES;
			evc.title = @"旅游";
			[self.navigationController pushViewController:evc animated:NO];
		}
		
		if ([searchValue isEqualToString:@"2"]) {
			OQJExploreViewCon1 * evc = [[OQJExploreViewCon1 alloc]init];
			evc.classCount = 2;
			evc.title = @"家居";
			
			evc.hidesBottomBarWhenPushed = YES;
			[self.navigationController pushViewController:evc animated:NO];
		}
		
		if ([searchValue isEqualToString:@"3"]) {
			OQJExploreViewCon1 * evc = [[OQJExploreViewCon1 alloc]init];
			evc.classCount = 3;
			evc.title = @"汽车";
			
			evc.hidesBottomBarWhenPushed = YES;
			[self.navigationController pushViewController:evc animated:NO];
		}
		
		if ([searchValue isEqualToString:@"4"]) {
			OQJExploreViewCon1 * evc = [[OQJExploreViewCon1 alloc]init];
			evc.classCount = 4;
			evc.title = @"美食";
			
			evc.hidesBottomBarWhenPushed = YES;
			[self.navigationController pushViewController:evc animated:NO];
		}
		
		if ([searchValue isEqualToString:@"5"]) {
			OQJExploreViewCon1 * evc = [[OQJExploreViewCon1 alloc]init];
			evc.classCount = 5;
			evc.title = @"时尚";
			
			evc.hidesBottomBarWhenPushed = YES;
			[self.navigationController pushViewController:evc animated:NO];
		}
	}
	else if ([Type isEqualToString:@"category"]) {
		OWTCategory * category = [[OWTCategory alloc]init];
		OWTCategoryViewCon * categoryViewCon = [[OWTCategoryViewCon alloc] initWithCategory:category];
		categoryViewCon.ifNeedSetbackground = YES;
		category.feedID = searchValue;
		// category.categoryID = searchValue;
		categoryViewCon.hidesBottomBarWhenPushed = YES;
		
		[self.navigationController pushViewController:categoryViewCon animated:YES];
		NSLog(@"categoryTypeHere");
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)showAuthViewCon
{
	OWTAuthManager * am = GetAuthManager();
	
	am.cancelBlock = ^{
		[self.navigationController popViewControllerAnimated:YES];
	};
	
	[am showAuthViewConWithSuccess:^{}
	cancel:^{
		OWTUserManager * um = GetUserManager();
	}];
}

#pragma mark 下拉框的跳转
- (void)presentHomeFeed
{
	OWTAuthManager * am = GetAuthManager();
	
	if (!am.isAuthenticated) {
		[self showAuthViewCon];
	}
	else {
		LJCollectionViewController * lvc = [[LJCollectionViewController alloc]init];
		lvc.isLike = YES;
		[_tabBarHider hideTabBar];
		lvc.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:lvc animated:YES];
	}
}

- (void)presentLatestFeed
{
	OWTAuthManager * am = GetAuthManager();
	
	if (!am.isAuthenticated) {
		[self showAuthViewCon];
	}
	else {
		LJCollectionViewController * lvc = [[LJCollectionViewController alloc]init];
		[_tabBarHider hideTabBar];
		lvc.hidesBottomBarWhenPushed = YES;
		
		[self.navigationController pushViewController:lvc animated:YES];
	}
}

- (void)presentSMSInvite
{
	OWTAuthManager * am = GetAuthManager();
	
	if (!am.isAuthenticated) {
		[self showAuthViewCon];
	}
	else {
		OWTSMSInviteViewCon * ovc = [[OWTSMSInviteViewCon alloc]init];
		ovc.hidesBottomBarWhenPushed = YES;
		[_tabBarHider hideTabBar];
		
		[self.navigationController pushViewController:ovc animated:YES];
	}
}

- (void)presentSquare
{
	OWTAuthManager * am = GetAuthManager();
	
	if (!am.isAuthenticated) {
		[self showAuthViewCon];
	}
	else {
		OQJSelectedViewCon2 * followerUsersViewCon = [[OQJSelectedViewCon2 alloc] initWithNibName:nil bundle:nil];
		//    followerUsersViewCon.user = _user;
		[_tabBarHider hideTabBar];
		followerUsersViewCon.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:followerUsersViewCon animated:YES];
	}
}

@end
