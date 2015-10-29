//
//  LJExploreViewController1.m
//  Weitu
//
//  Created by qj-app on 15/9/16.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJExploreViewController1.h"
#import "OWaterFlowCollectionView.h"
#import "OWaterFlowLayout.h"
#import "XHRefreshControl.h"
#import "OWTImageCell.h"
#import "OWTCategoryManager.h"
#import "OWTCategoryViewCon.h"
#import "OWTSearchViewCon.h"
#import <FontAwesomeKit/FontAwesomeKit.h>

#import "UIView+EasyAutoLayout.h"
#import "SVProgressHUD+WTError.h"
#import <SVPullToRefresh/SVPullToRefresh.h>

#import "WLJWebViewController.h"
#import "UIViewController+WTExt.h"

#import "exploreViewController.h"

#import "JCTopic.h"
#import "OWTUser.h"
#import "OWTUserManager.h"
#import "OWTCategoryListViewCon.h"
#import "OWTexploreModel.h"
#import "MJRefresh.h"
#import "ASIHTTPRequest.h"
#import "OQJExploreViewCon1.h"
#import "OWTUserManager.h"
#import "NetStatusMonitor.h"
#import "UIColor+HexString.h"
#import "LJExploreViewCellTableViewCell.h"
#import "QuanJingSDK.h"
static NSString * kCategoryCellID = @"kCategoryCellID";

static const int kDefaultLoadItemNum1 = 10;

@interface LJExploreViewController1 () <ASIHTTPRequestDelegate, UIScrollViewDelegate>
{
	//    NSMutableArray *showArr;
	NSArray * arrAll;
	XHRefreshControl * _refreshControl;
	NSMutableArray * dataArr;
	OWTUser * _user;
}

@property (nonatomic, strong) OWaterFlowLayout * waterFlowLayout;
@property (nonatomic, strong) XHRefreshControl * refreshControl;
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, copy) NSMutableArray * categories;

@property (nonatomic, copy) NSArray * seArr;

@property (nonatomic, copy) NSArray * titleArr;
@property (nonatomic, copy) NSArray * titleArr1;
@property (nonatomic, strong) JCTopic * Topic;
@property (nonatomic, strong)  UILabel * label1;
@property (strong, nonatomic)  UILabel * label2;
@property (strong, nonatomic)  UIPageControl * page;

@property (nonatomic, assign) NSInteger pageCount;
// @property (strong, nonatomic)  SHPage *pageN;
@property (nonatomic, strong) OWTCategoryListViewCon * categoryListViewCon;

@end

@implementation LJExploreViewController1
{
	BOOL isFirst;
	UIScrollView * _scrollView;
	NSMutableArray * _categories1;
	NSMutableArray * _categories2;
	NSMutableArray * _categories3;
	NSMutableArray * _categories4;
	NSMutableArray * _categories5;
	NSMutableArray * pages;
	NSMutableArray * _categoriesList;
	NSArray * _arr;
	UITableView * currentTableView;
	UIView * _view;
	UIColor * _titleColor0;
	UIColor * _titleColor1;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
	_categories1 = [[NSMutableArray alloc]init];
	_categories2 = [[NSMutableArray alloc]init];
	_categories3 = [[NSMutableArray alloc]init];
	_categories4 = [[NSMutableArray alloc]init];
	_categories5 = [[NSMutableArray alloc]init];
	_categoriesList = [[NSMutableArray alloc]init];
	pages = [[NSMutableArray alloc]init];
	_titleColor0 = [UIColor colorWithHexString:@"2b2b2b"];
	_titleColor1 = [UIColor colorWithHexString:@"#ff2a00"];
	
	for (NSInteger i = 0; i < 6; i++) {
		NSString * str = @"1";
		[pages addObject:str];
	}
	
	_pageCount = 0;
	
	_titleArr1 = @[@"旅游", @"家居", @"汽车", @"美食", @"时尚", @"百科"];
	
	//    dataArr = [[NSMutableArray alloc]init];
	isFirst = YES;
	_categories = [[NSMutableArray alloc]init];
	_user = GetUserManager().currentUser;
	[self setUpNavigationBar];
	[self setUpScrollView];
	[self setUpTabelView];
}

#pragma mark setUpView
- (void)setUpNavigationBar
{
	NSDictionary * dict = [NSDictionary dictionaryWithObject:[UIColor colorWithHexString:@"#f6f6f6"] forKey:UITextAttributeTextColor];
	
	self.navigationController.navigationBar.titleTextAttributes = dict;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[[QJInterfaceManager sharedManager]requestArticleCategory:^(NSArray * _Nonnull articleCategoryArray, NSArray * _Nonnull resultArray, NSError * _Nonnull error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[_categoriesList addObjectsFromArray:articleCategoryArray];
				QJArticleCategory * model = [[QJArticleCategory alloc]init];
				model.name = @"全部";
				[_categoriesList insertObject:model atIndex:0];
				_view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, 30)];
				_view.backgroundColor = [UIColor colorWithRed:246 / 255.0 green:246 / 255.0 blue:246 / 255.0 alpha:1.0];
				
				for (int i = 0; i < 6; i++) {
					QJArticleCategory * model = _categoriesList[i];
					UIButton * btn = [LJUIController createButtonWithFrame:CGRectMake(SCREENWIT / 6 * i, 5, SCREENWIT / 6, 20) imageName:nil title:model.name target:self action:@selector(naviClick:)];
					btn.titleLabel.font = [UIFont systemFontOfSize:12];
					
					//        btn.titleLabel.font=[UIFont fontWithName:@"冬青黑体" size:12];
					if (i == 0) {
						[btn setBackgroundImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
						[btn setTitleColor:_titleColor1 forState:UIControlStateNormal];
					}
					else {
						[btn setTitleColor:_titleColor0 forState:UIControlStateNormal];
					}
					btn.tag = 300 + i;
					[_view addSubview:btn];
				}
				
				[self.view addSubview:_view];
				[currentTableView headerBeginRefreshing];
			});
		}];
	});
}

- (void)setUpScrollView
{
	_scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 30, SCREENWIT, SCREENHEI - 64 - 30 - 42)];
	_scrollView.delegate = self;
	_scrollView.contentSize = CGSizeMake(SCREENWIT * 6, SCREENHEI - 64 - 30 - 42);
	_scrollView.pagingEnabled = YES;
	[self.view addSubview:_scrollView];
}

- (void)setUpTabelView
{
	for (NSInteger i = 0; i < 6; i++) {
		UITableView * _tableView = [[UITableView alloc]initWithFrame:CGRectMake(SCREENWIT * i, 0, SCREENWIT, SCREENHEI - 64 - 30 - 42)];
		_tableView.delegate = self;
		_tableView.dataSource = self;
		_tableView.tag = 200 + i;
		//    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		[self setupRefreshWithTableView:_tableView];
		[_tableView registerNib:[UINib nibWithNibName:@"OWTCategoryTableViewCell" bundle:nil]
		forCellReuseIdentifier:kCategoryCellID];
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		//        _tableView.backgroundColor = [UIColor colorWithHexString:@"#f6f6f6"];
		[_scrollView addSubview:_tableView];
	}
	
	for (UIView * view in _scrollView.subviews)
		if (view.tag == 200 + _pageCount)
			currentTableView = (UITableView *)view;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)setupRefreshWithTableView:(UITableView *)tableView;
{
	self.title = @"发现";
	tableView.allowsSelection = YES;
	UIImage * searchImage = [[FAKFontAwesome searchIconWithSize:22] imageWithSize:CGSizeMake(22, 22)];
	searchImage = [searchImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	[tableView addHeaderWithTarget:self action:@selector(refresh) dateKey:@"table"];
	//    [self.tableView headerBeginRefreshing];
	[tableView addFooterWithTarget:self action:@selector(reloadData2)];
	tableView.headerPullToRefreshText = @" ";
	tableView.headerReleaseToRefreshText = @" ";
	tableView.headerRefreshingText = @" ";
	tableView.footerPullToRefreshText = @" ";
	tableView.footerReleaseToRefreshText = @" ";
	tableView.footerRefreshingText = @" ";
	tableView.allowsSelection = YES;
}
#pragma mark scrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if (scrollView == _scrollView) {
		_pageCount = scrollView.contentOffset.x / SCREENWIT;
		
		for (UIView * view in _scrollView.subviews)
			if (view.tag == 200 + _pageCount)
				currentTableView = (UITableView *)view;
				
		if (_pageCount == 0)
			_arr = _categories;
		else if (_pageCount == 1)
			_arr = _categories1;
		else if (_pageCount == 2)
			_arr = _categories2;
		else if (_pageCount == 3)
			_arr = _categories3;
		else if (_pageCount == 4)
			_arr = _categories4;
		else
			_arr = _categories5;
		//        [currentTableView headerBeginRefreshing];
		
		if (_arr.count == 0)
			[currentTableView headerBeginRefreshing];
		else
			[currentTableView reloadData];
	}
	
	for (UIView * view in _view.subviews) {
		if (view.tag == 300 + _pageCount) {
			UIButton * btn = (UIButton *)view;
			[btn setBackgroundImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
			[btn setTitleColor:_titleColor1 forState:UIControlStateNormal];
		}
		else {
			UIButton * btn = (UIButton *)view;
			[btn setBackgroundImage:nil forState:UIControlStateNormal];
			[btn setTitleColor:_titleColor0 forState:UIControlStateNormal];
		}
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{}

#pragma mark clickAndTap
- (void)naviClick:(UIButton *)sender
{
	NSInteger i = sender.tag - 300;
	
	for (UIView * view in _view.subviews) {
		if (view.tag == sender.tag) {
			UIButton * btn = (UIButton *)view;
			[btn setBackgroundImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
			[btn setTitleColor:_titleColor1 forState:UIControlStateNormal];
		}
		else {
			UIButton * btn = (UIButton *)view;
			[btn setBackgroundImage:nil forState:UIControlStateNormal];
			[btn setTitleColor:_titleColor0 forState:UIControlStateNormal];
		}
	}
	
	[_scrollView setContentOffset:CGPointMake(SCREENWIT * i, 0) animated:YES];
	_pageCount = i;
	
	for (UIView * view in _scrollView.subviews)
		if (view.tag == 200 + _pageCount)
			currentTableView = (UITableView *)view;
			
	if (_pageCount == 0)
		_arr = _categories;
	else if (_pageCount == 1)
		_arr = _categories1;
	else if (_pageCount == 2)
		_arr = _categories2;
	else if (_pageCount == 3)
		_arr = _categories3;
	else if (_pageCount == 4)
		_arr = _categories4;
	else
		_arr = _categories5;
	//        [currentTableView headerBeginRefreshing];
	
	if (_arr.count == 0) {
		[currentTableView headerBeginRefreshing];
	}
	else {
		[currentTableView reloadData];
		[currentTableView headerBeginRefreshing];
	}
	[self performSelector:@selector(endrefresh) withObject:nil afterDelay:3];
}

- (void)endrefresh
{
	[currentTableView headerEndRefreshing];
}

- (void)reloadData2
{
	NSString * page = pages[_pageCount];
	NSInteger page1 = page.intValue;
	
	page1++;
	[pages replaceObjectAtIndex:_pageCount withObject:[NSString stringWithFormat:@"%ld", (long)page1]];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		QJArticleCategory * model = _categoriesList[_pageCount];
		
		if (_arr.count == 0)
			return;
			
		QJArticleObject * model1 = [_arr lastObject];
		[[QJInterfaceManager sharedManager]requestArticleList:model.cid cursorIndex:model1.aid pageSize:30 finished:^(NSArray * _Nonnull articleObjectArray, NSNumber * _Nonnull nextCursorIndex, NSArray * _Nonnull resultArray, NSError * _Nonnull error) {
			if (_pageCount == 0)
			
				[_categories addObjectsFromArray:articleObjectArray];
			else if (_pageCount == 1)
			
				[_categories1 addObjectsFromArray:articleObjectArray];
				
			else if (_pageCount == 2)
			
				[_categories2 addObjectsFromArray:articleObjectArray];
				
			else if (_pageCount == 3)
			
				[_categories3 addObjectsFromArray:articleObjectArray];
				
			else if (_pageCount == 4)
				[_categories4 addObjectsFromArray:articleObjectArray];
				
			else
				[_categories5 addObjectsFromArray:articleObjectArray];
				
			dispatch_async(dispatch_get_main_queue(), ^{
				[self reloadTableView];
				[currentTableView footerEndRefreshing];
			});
		}];
	});
}

- (void)reloadData3
{
	NSString * page = pages[_pageCount];
	NSInteger page1 = page.intValue;
	
	page1++;
	[pages replaceObjectAtIndex:_pageCount withObject:[NSString stringWithFormat:@"%ld", (long)page1]];
	NSString * str;
	NSInteger i;
	i = _pageCount;
	
	if (_pageCount == 0) {
		i = 10;
		str = [NSString stringWithFormat:@"http://api.tiankong.com/qjapi/cdn1/articleFound?count=%ld&page=%ld", (long)i, (long)page1];
	}
	else {
		if (_pageCount >= 3)
			i = _pageCount + 1;
		str = [NSString stringWithFormat:@"http://api.tiankong.com/qjapi/cdn1/article?count=10&&type=%ld&page=%ld", (long)i, (long)page1];
	}
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSURL * url = [NSURL URLWithString:str];
		
		// 利用三方解析json数据
		
		NSURLRequest * request = [NSURLRequest requestWithURL:url];
		NSData * response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
		
		// NSJSONSerialization解析
		if (response != nil) {
			NSDictionary * dic0 = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:nil];
			
			NSLog(@"dic0 =%@", dic0);
			
			if (response != nil) {
				NSArray * appList = dic0[@"article"];
				
				for (NSDictionary * appdict in appList) {
					OWTexploreModel * model = [[OWTexploreModel alloc]init];
					
					for (NSString * key in appdict) {
						if ([appdict[key] isKindOfClass:[NSNull class]])
							// do something
							[model setValue:@"" forKey:key];
						else
							// do something
							[model setValue:appdict[key] forKey:key];
							
					}
					
					if (_pageCount == 0)
						[_categories addObject:model];
					else if (_pageCount == 1)
						[_categories1 addObject:model];
					else if (_pageCount == 2)
						[_categories2 addObject:model];
					else if (_pageCount == 3)
						[_categories3 addObject:model];
					else if (_pageCount == 4)
						[_categories4 addObject:model];
					else
						[_categories5 addObject:model];
						
				}
			}
			
			[currentTableView reloadData];
		}
		//    else {
		//        [SVProgressHUD showWithStatus:@"没有了" ];
		//    }
		[currentTableView footerEndRefreshing];
	});
}

- (void)reloadTableView
{
	if (_pageCount == 0)
		_arr = _categories;
	else if (_pageCount == 1)
		_arr = _categories1;
	else if (_pageCount == 2)
		_arr = _categories2;
	else if (_pageCount == 3)
		_arr = _categories3;
	else if (_pageCount == 4)
		_arr = _categories4;
	else
		_arr = _categories5;
	[currentTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

///要修改
- (void)refresh
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		QJArticleCategory * model = _categoriesList[_pageCount];
		[[QJInterfaceManager sharedManager]requestArticleList:model.cid cursorIndex:nil pageSize:30 finished:^(NSArray * _Nonnull articleObjectArray, NSNumber * _Nonnull nextCursorIndex, NSArray * _Nonnull resultArray, NSError * _Nonnull error) {
			if (_pageCount == 0) {
				[_categories removeAllObjects];
				[_categories addObjectsFromArray:articleObjectArray];
			}
			else if (_pageCount == 1) {
				[_categories1 removeAllObjects];
				[_categories1 addObjectsFromArray:articleObjectArray];
			}
			else if (_pageCount == 2) {
				[_categories2 removeAllObjects];
				[_categories2 addObjectsFromArray:articleObjectArray];
			}
			else if (_pageCount == 3) {
				[_categories3 removeAllObjects];
				[_categories3 addObjectsFromArray:articleObjectArray];
			}
			else if (_pageCount == 4) {
				[_categories4 removeAllObjects];
				[_categories4 addObjectsFromArray:articleObjectArray];
			}
			else {
				[_categories5 removeAllObjects];
				[_categories5 addObjectsFromArray:articleObjectArray];
			}
			dispatch_async(dispatch_get_main_queue(), ^{
				[self reloadTableView];
				[currentTableView headerEndRefreshing];
			});
		}];
	});
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (tableView != currentTableView)
		return 0;
		
	return _arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString * identifier = @"LJExploreCell1";
	LJExploreViewCellTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (!cell)
		cell = [[LJExploreViewCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	QJArticleObject * model = _arr[indexPath.row];
	[cell customTheView:model];
	return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	QJArticleObject * category = _arr[indexPath.row];
	CGSize size = [category.summary sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(SCREENWIT - 20, 200)];
	
	return 210 + size.height + 10;
}

#pragma mark - UICollectionViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	QJArticleObject * category;
	
	if (_pageCount == 0)
		category = _categories[indexPath.row];
	else if (_pageCount == 1)
		category = _categories1[indexPath.row];
	else if (_pageCount == 2)
		category = _categories2[indexPath.row];
		
	else if (_pageCount == 3)
		category = _categories3[indexPath.row];
		
	else if (_pageCount == 4)
		category = _categories4[indexPath.row];
		
	else
		category = _categories5[indexPath.row];
		
		
	WLJWebViewController * evc = [[WLJWebViewController alloc]init];
	
	//
	evc.SummaryStr = category.summary;
	//    //
	evc.titleS = category.title;
	evc.urlString = category.url;
	evc.assetUrl = category.coverUrl;
	[self.navigationController pushViewController:evc animated:YES];
	[evc substituteNavigationBarBackItem];
	
	//    OWTCategoryViewCon* categoryViewCon = [[OWTCategoryViewCon alloc] initWithCategory:category];
	//    [self.navigationController pushViewController:categoryViewCon animated:YES];
}

#pragma mark - ScrollView Delegate

//
#pragma mark -

//
- (void)search
{
	OWTSearchViewCon * searchViewCon = [[OWTSearchViewCon alloc] initWithNibName:nil bundle:nil];
	
	[self.navigationController pushViewController:searchViewCon animated:YES];
}

@end
