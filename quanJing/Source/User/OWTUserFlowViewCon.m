//
//  OWTUsersListViewCon.m
//  Weitu
//
//  Created by Su on 6/16/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUserFlowViewCon.h"
#import "ORefreshControl.h"
#import "OWaterFlowLayout.h"
#import "OWTTabBarHider.h"
#import "OWaterFlowCollectionView.h"
#import "OWTUserFellowshipCell.h"
#import "OWTUser.h"
#import "UIView+EasyAutoLayout.h"
#import <SVPullToRefresh/SVPullToRefresh.h>
#import "QuanJingSDK.h"
#import "MJRefresh.h"

static NSString * kWaterFlowCellID = @"kWaterFlowCellID";

@interface OWTUserFlowViewCon ()
{
	OWTTabBarHider * _tabBarHider;
	UIBarButtonItem * _numItem;
}

@property (nonatomic, strong) OWaterFlowLayout * waterFlowLayout;
@property (nonatomic, strong) XHRefreshControl * refreshControl;
@property (nonatomic, strong) UICollectionView * collectionView;

@end

@implementation OWTUserFlowViewCon
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	if (self)
		[self setup];
	return self;
}

- (void)setup
{
	_dataResouce = [[NSMutableArray alloc]init];
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
	
	[self reloadData];
}

- (void)setupCollectionView
{
	_waterFlowLayout = [[OWaterFlowLayout alloc] init];
	_waterFlowLayout.sectionInset = UIEdgeInsetsMake(5, 10, 5, 10);
	_waterFlowLayout.columnCount = 2;
	
	_collectionView = [[OWaterFlowCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:_waterFlowLayout];
	_collectionView.delegate = self;
	_collectionView.dataSource = self;
	_collectionView.backgroundColor = GetThemer().themeColorBackground;
	_collectionView.showsHorizontalScrollIndicator = NO;
	_collectionView.showsVerticalScrollIndicator = NO;
	_collectionView.alwaysBounceVertical = YES;
	
	[_collectionView registerNib:[UINib nibWithNibName:@"OWTUserFellowshipCell" bundle:nil] forCellWithReuseIdentifier:kWaterFlowCellID];
	
	_collectionView.translatesAutoresizingMaskIntoConstraints = NO;
	
	[self.view addSubview:_collectionView];
	[_collectionView easyFillSuperview];
	[_collectionView addHeaderWithTarget:self action:@selector(refreshData)];
	[_collectionView addFooterWithTarget:self action:@selector(loadMoreData)];
	//    [_collectionView headerBeginRefreshing];
	_collectionView.headerPullToRefreshText = nil;
	_collectionView.headerRefreshingText = nil;
	_collectionView.headerReleaseToRefreshText = nil;
	_collectionView.footerPullToRefreshText = nil;
	_collectionView.footerRefreshingText = nil;
	_collectionView.footerReleaseToRefreshText = nil;
}

- (void)reloadData
{
	[_collectionView reloadData];
}

- (void)manualRefresh
{
	if (_refreshDataFunc == nil)
		return;
		
	[_collectionView headerBeginRefreshing];
}

- (void)refreshData
{
	if (_refreshDataFunc == nil)
		return;
		
	_refreshDataFunc(^{
		[_collectionView headerEndRefreshing];
		[self reloadData];
	});
}

- (void)loadMoreData
{
	if (_loadMoreDataFunc == nil) {
		[_collectionView footerEndRefreshing];
		return;
	}
	
	_loadMoreDataFunc(^
	{
		[self.collectionView reloadData];
		[_collectionView footerEndRefreshing];
	});
}

- (void)setTotalUserNum:(NSNumber *)totalUserNum
{
	_totalUserNum = totalUserNum;
	
	if (_totalUserNum != nil)
		if ((self.parentViewController != nil) &&
			((self.parentViewController.navigationItem.rightBarButtonItem == nil) || (self.parentViewController.navigationItem.rightBarButtonItem == _numItem))) {
			if (_numItem == nil) {
				_numItem = [[UIBarButtonItem alloc] initWithTitle:@""
					style:UIBarButtonItemStyleBordered
					target:nil
					action:nil];
				self.parentViewController.navigationItem.rightBarButtonItem = _numItem;
			}
			
			_numItem.title = [NSString stringWithFormat:@"%d", _totalUserNum.integerValue];
		}
}

#pragma mark - OWaterFlowLayoutDataSource

- (OWTUser *)userAtIndex:(NSUInteger)index
{
	if (_userAtIndexFunc == nil)
		return nil;
		
	return _userAtIndexFunc(index);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
	layout:(UICollectionViewLayout *)collectionViewLayout
	sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return CGSizeMake(145, 155);
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return _dataResouce.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	OWTUserFellowshipCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kWaterFlowCellID forIndexPath:indexPath];
	
	QJUser * user = _dataResouce[indexPath.row];
	
	[cell setUser:user isFollowerUser:_isShowingFollowerUsers];
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

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	QJUser * user = _dataResouce[indexPath.row];
	
	if (user != nil)
		if (_onUserSelectedFunc != nil)
			_onUserSelectedFunc(user);
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
