//
//  LJSearchViewController.m
//  Weitu
//
//  Created by qj-app on 15/9/8.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJSearchViewController.h"
#import "OWTSearchResultsViewCon.h"
#import "LJSearchCell.h"
#import "UIColor+HexString.h"
#import "OWaterFlowLayout.h"
#import "OWTImageCell.h"
#import "QuanJingSDK.h"
#import "MobClick.h"
#import "LJSearchCell.h"
#import "SVProgressHUD+WTError.h"
#import "OWTImageInfo.h"
#import "OWTAssetViewCon.h"
#import "OWTPhotoUploadTagButton.h"
#import "OWTTabBarHider.h"
#import "UIScrollView+MJRefresh.h"

static NSString * kWaterFlowCellID = @"kWaterFlowCellID";
@interface LJSearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, NSURLConnectionDataDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSString * keyword;
@property (nonatomic, strong) NSMutableOrderedSet * assets;
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) OWaterFlowLayout * collectionViewLayout;
@end

@implementation LJSearchViewController
{
	UISearchBar * _searchBar;
	UITableView * _tableView;
	NSURLConnection * _connection;
	NSMutableData * _data;
	NSMutableArray * _dataArr;
	NSUserDefaults * _userDefault;
	BOOL isHistory;
	UIView * _footerView;
	UIImageView * _imageView1;
}
- (void)viewDidLoad
{
	[super viewDidLoad];
	[self setUpData];
	[self setUpFooterView];
	[self setUpNavigation];
	[self setupCollectionView];
	[self setUpTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
	for (UIView * view in self.navigationController.view.subviews)
		if ((view.tag == 111) || (view.tag == 333))
			view.hidden = NO;
			
	[[[OWTTabBarHider alloc]init]showTabBar];
	[self getUpHistoryData];
}

#pragma mark setUpView
- (void)setUpData
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	_data = [[NSMutableData alloc]init];
	_dataArr = [[NSMutableArray alloc]init];
	_userDefault = [NSUserDefaults standardUserDefaults];
	_assets = [[NSMutableOrderedSet alloc]init];
}

- (void)setUpFooterView
{
	_footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, 30)];
	_footerView.backgroundColor = [UIColor whiteColor];
	UILabel * clearLabel = [LJUIController createLabelWithFrame:CGRectMake(100, 0, 200, 30) Font:14 Text:@"清除历史纪录"];
	clearLabel.textColor = [UIColor blackColor];
	clearLabel.userInteractionEnabled = YES;
	[_footerView addSubview:clearLabel];
	UILabel * line = [LJUIController createLabelWithFrame:CGRectMake(0, 29.8, SCREENWIT, 0.2) Font:12 Text:nil];
	line.backgroundColor = [UIColor blackColor];
	[_footerView addSubview:line];
	[_footerView addSubview:clearLabel];
	UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clearHistory)];
	[_footerView addGestureRecognizer:tap];
}

- (void)setUpNavigation
{
	UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 20, SCREENWIT, 44)];
	
	//    view.backgroundColor=[UIColor blackColor];
	[self SetUpsearchView];
	[view addSubview:_searchBar];
	view.tag = 111;
	UIButton * cancel = [LJUIController createButtonWithFrame:CGRectMake(SCREENWIT - 50, 2, 50, 40) imageName:nil title:@"取消" target:self action:@selector(cancelClick)];
	[cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[view addSubview:cancel];
	[self.navigationController.view addSubview:view];
}

- (void)SetUpsearchView
{
	// self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:23/255.0f green:200/255.0f  blue:184/255.0f alpha:1.0f];
	_searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 2, SCREENWIT - 50, 40)];
	_searchBar.delegate = self;
	_searchBar.placeholder = @"搜图片";
	_searchBar.userInteractionEnabled = YES;
	_searchBar.translucent = NO;
	_searchBar.tintColor = [UIColor lightGrayColor];
	_searchBar.searchBarStyle = UISearchBarStyleMinimal;
	[_searchBar becomeFirstResponder];
	[_searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"SearchBarBG"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)]
	forState:UIControlStateNormal];
	[_searchBar.layer setBorderColor:[UIColor redColor].CGColor];
}

- (void)setUpTableView
{
	_tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, SCREENHEI - 64 - 5) style:UITableViewStyleGrouped];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];
	[_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	_tableView.backgroundColor = [UIColor whiteColor];
}

- (void)setupCollectionView
{
	_collectionViewLayout = [[OWaterFlowLayout alloc] init];
	_collectionViewLayout.sectionInset = UIEdgeInsetsMake(5, 10, 5, 10);
	_collectionViewLayout.columnCount = 2;
	
	CGRect frame = self.view.bounds;
	frame.size.height -= 106.0;
	self.collectionView = [[UICollectionView alloc] initWithFrame:frame
		collectionViewLayout:_collectionViewLayout];
	self.collectionView.delegate = self;
	self.collectionView.dataSource = self;
	
	[self.view addSubview:_collectionView];
	
	self.view.backgroundColor = GetThemer().themeColorBackground;
	
	[self.collectionView registerClass:OWTImageCell.class forCellWithReuseIdentifier:kWaterFlowCellID];
	
	self.collectionView.backgroundColor = GetThemer().themeColorBackground;
	self.collectionView.showsHorizontalScrollIndicator = NO;
	self.collectionView.showsVerticalScrollIndicator = NO;
	
	self.collectionView.alwaysBounceVertical = YES;
	
	// 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
	[_collectionView addFooterWithTarget:self action:@selector(loadMoreData)];
	
	_collectionView.footerPullToRefreshText = @"";
	_collectionView.footerReleaseToRefreshText = @"";
	_collectionView.footerRefreshingText = @"";
}

- (void)setUpBackView
{
	_imageView1 = [LJUIController createImageViewWithFrame:CGRectMake(0, 0, 100, 100) imageName:@"seach"];
	//    _imageView1.backgroundColor=[UIColor blackColor];
	_imageView1.hidden = YES;
	//    _imageView1.center=self.view.center;
	_imageView1.center = CGPointMake(self.view.center.x, self.view.center.y - 50);
	[self.view addSubview:_imageView1];
}

- (void)getUpHistoryData
{
	[_dataArr removeAllObjects];
	NSArray * arr = [_userDefault arrayForKey:@"searchHistory"];
	[_dataArr addObjectsFromArray:arr];
	isHistory = YES;
	[_tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)setSearchWord:(NSString *)keyword
{
	self.keyword = keyword;
	[self loadMoreData];
	[self.view bringSubviewToFront:_collectionView];
	[self updateSearbarButtons:_keyword];
	[_searchBar resignFirstResponder];
}

#pragma mark 网络请求
- (void)loadMoreData
{
	QJInterfaceManager * fm = [QJInterfaceManager sharedManager];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[fm requestImageSearchKey:_keyword pageNum:_assets.count / 50 + 1 pageSize:50 currentImageId:nil finished:^(NSArray * imageObjectArray, NSArray * resultArray, NSError * error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (error) {
					[_collectionView footerEndRefreshing];
					[SVProgressHUD showError:error];
					return;
				}
				
				if (imageObjectArray.count == 0) {
					if (_assets.count == 0)
						[self.view bringSubviewToFront:_imageView1];
					_imageView1.hidden = NO;
				}
				else {
					_imageView1.hidden = YES;
				}
				
				[SVProgressHUD dismiss];
				
				[_collectionView footerEndRefreshing];
				[self mergeAssets:imageObjectArray];
			});
		}];
	});
}

- (void)mergeAssets:(NSArray *)assets
{
	if (assets.count > 0)
		[_assets addObjectsFromArray:assets];
	[_collectionView reloadData];
}

#pragma mark searchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar					// called when
{
	NSArray * arr = [_userDefault arrayForKey:@"searchHistory"];
	NSMutableArray * arr1 = [[NSMutableArray alloc]initWithArray:arr];
	NSInteger number = 0;
	
	for (NSString * searchStr in arr1) {
		if ([searchStr isEqualToString:searchBar.text])
			break;
		number++;
	}
	
	if (number < arr1.count)
		[arr1 removeObjectAtIndex:number];
		
	if (arr1.count >= 10) {
		[arr1 insertObject:searchBar.text atIndex:0];
		[arr1 removeLastObject];
	}
	else {
		[arr1 insertObject:searchBar.text atIndex:0];
	}
	[_userDefault setObject:arr1 forKey:@"searchHistory"];
	[_userDefault synchronize];
	_keyword = _searchBar.text;
	[_assets removeAllObjects];
	[self loadMoreData];
	[self updateSearbarButtons:_keyword];
	[self.view bringSubviewToFront:_collectionView];
	[_searchBar resignFirstResponder];
	_searchBar.text = @"";
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	[self.view bringSubviewToFront:_tableView];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	if (searchText.length > 0)
		[self getImageData:searchText];
}

- (void)updateSearbarButtons:(NSString *)searchtext
{
	UIView * backImage = [[UIView alloc]initWithFrame:CGRectMake(8, 26, SCREENWIT - 65, 30)];
	
	backImage.layer.cornerRadius = 2;
	backImage.backgroundColor = [UIColor whiteColor];
	backImage.userInteractionEnabled = YES;
	UIImageView * back1 = [LJUIController createImageViewWithFrame:CGRectMake(0, 0, SCREENWIT - 65, 30) imageName:nil];
	[backImage addSubview:back1];
	UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBackImage:)];
	[back1 addGestureRecognizer:tap];
	NSArray * arr = [searchtext componentsSeparatedByString:@" "];
	__block float witch = 0;
	[arr enumerateObjectsUsingBlock:^(NSString * tagStr, NSUInteger idx, BOOL * _Nonnull stop) {
		if (!tagStr || (tagStr.length == 0))
			return;
			
		UIFont * font = [UIFont systemFontOfSize:13.0];
		CGRect frame = [tagStr boundingRectWithSize:CGSizeMake(NSUIntegerMax, NSUIntegerMax)
		options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
		attributes:@{NSFontAttributeName: font}
		context:nil];
		frame.size.width += 30.0;
		
		if (witch + frame.size.width + 2 + 5 > SCREENWIT - 65)
			return;
			
		OWTPhotoUploadTagButton * button = [[OWTPhotoUploadTagButton alloc] initWithFrame:CGRectMake(5 + witch, 2.5, frame.size.width, 25.0)];
		button.tag = 900 + idx;
		witch += (frame.size.width + 2);
		[button addTarget:self action:@selector(deleteTag1:) forControlEvents:UIControlEventTouchUpInside];
		button.title = tagStr;
		////        int value = arc4random() % 3;
		//        NSString *imgStr = [NSString stringWithFormat:@"上传图片tag%@.png", _imageArray[value]];
		UIImage * image = [UIImage imageNamed:@"上传图片tag红.png"];
		button.imageView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 2.0, 0.0, 27.0)];
		[backImage addSubview:button];
	}];
	backImage.tag = 333;
	[self.navigationController.view addSubview:backImage];
}

#pragma mark 请求数据
- (void)getImageData:(NSString *)searchText
{
	NSString * urlString = [NSString stringWithFormat:@"http://api.tiankong.com/qjapi/searchtip/%@", searchText];
	NSString * encodedString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodedString]];
	
	_connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"%@", error);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[_data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (_data.length == 0)
		return;
		
	NSArray * arr = [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableContainers error:nil];
	[_dataArr removeAllObjects];
	
	if (arr.count != 1)
		[_dataArr addObjectsFromArray:arr];
	isHistory = NO;
	[_tableView reloadData];
}

#pragma mark tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _dataArr.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	if (isHistory && (_dataArr.count > 0))
		return _footerView;
		
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	if (isHistory)
		return 30;
		
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString * identifier = @"LJSearchCell";
	LJSearchCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (!cell)
		cell = [[NSBundle mainBundle] loadNibNamed:@"LJSearchCell" owner:self options:nil][0];
	cell.searchLabel.text = _dataArr[indexPath.row];
	
	if (isHistory)
		cell.searchImage.image = [UIImage imageNamed:@"搜索1_03.png"];
	else
		cell.searchImage.image = [UIImage imageNamed:@"搜索2_03.png"];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 30;
}

#pragma mark - OWaterFlowLayoutDataSource

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	QJImageObject * model = _assets[indexPath.row];
	
	if (model != nil)
		return CGSizeMake(model.width.intValue, model.height.intValue);
	else
		return CGSizeZero;
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	if (_assets != nil)
		return _assets.count;
	else
		return 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	OWTImageCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kWaterFlowCellID forIndexPath:indexPath];
	QJImageObject * model = _assets[indexPath.row];
	OWTImageInfo * imageInfo = [[OWTImageInfo alloc]init];
	
	imageInfo.url = model.url;
	imageInfo.width = model.width.intValue;
	imageInfo.height = model.height.intValue;
	imageInfo.primaryColorHex = model.bgcolor;
	
	if (model != nil) {
		if (imageInfo != nil)
			[cell setImageWithInfo:imageInfo];
		else
			cell.backgroundColor = [UIColor lightGrayColor];
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
	QJImageObject * model = _assets[indexPath.row];
	
	for (UIView * view in self.navigationController.view.subviews)
		if ((view.tag == 111) || (view.tag == 333))
			view.hidden = YES;
			
	if (model != nil) {
		model.imageType = [NSNumber numberWithInt:1];
		OWTAssetViewCon * assetViewCon = [[OWTAssetViewCon alloc]initWithImageId:model imageType:model.imageType];
		[self.navigationController pushViewController:assetViewCon animated:YES];
	}
}

#pragma mark tapAndClick
- (void)tapBackImage:(UIGestureRecognizer *)sender
{
	[_searchBar becomeFirstResponder];
	_searchBar.text = [NSString stringWithFormat:@"%@ ", _keyword];
	
	for (UIView * view in self.navigationController.view.subviews)
		if (view.tag == 333)
			[view removeFromSuperview];
}

- (void)deleteTag1:(OWTPhotoUploadTagButton *)sender
{
	[_searchBar becomeFirstResponder];
	NSMutableArray * arr = [[NSMutableArray alloc]init];
	NSArray * arr1 = [_keyword componentsSeparatedByString:@" "];
	NSString * str;
	
	if (arr1.count <= 1) {
		str = @"";
	}
	else {
		[arr1 enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
			if ([sender.title isEqualToString:obj] || (obj.length == 0))
				return;
				
			[arr addObject:obj];
		}];
		str = [NSString stringWithFormat:@"%@ ", [arr componentsJoinedByString:@" "]];
	}
	_searchBar.text = str;
	
	for (UIView * view in self.navigationController.view.subviews)
		if (view.tag == 333)
			[view removeFromSuperview];
}

- (void)clearHistory
{
	[_userDefault removeObjectForKey:@"searchHistory"];
	[_userDefault synchronize];
	[self getUpHistoryData];
}

- (void)cancelClick
{
	for (UIView * view in self.navigationController.view.subviews)
		if ((view.tag == 111) || (view.tag == 333))
			[view removeFromSuperview];
			
	[self.navigationController popViewControllerAnimated:NO];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray * arr = [_userDefault arrayForKey:@"searchHistory"];
	NSMutableArray * arr1 = [[NSMutableArray alloc]initWithArray:arr];
	NSInteger number = 0;
	
	for (NSString * searchStr in arr1) {
		if ([searchStr isEqualToString:_dataArr[indexPath.row]])
			break;
		number++;
	}
	
	if (number < arr1.count)
		[arr1 removeObjectAtIndex:number];
		
	if (arr1.count >= 10) {
		[arr1 insertObject:_dataArr[indexPath.row] atIndex:0];
		[arr1 removeLastObject];
	}
	else {
		[arr1 insertObject:_dataArr[indexPath.row] atIndex:0];
	}
	[_userDefault setObject:arr1 forKey:@"searchHistory"];
	[_userDefault synchronize];
	_keyword = _dataArr[indexPath.row];
	[_assets removeAllObjects];
	[self loadMoreData];
	[self.view bringSubviewToFront:_collectionView];
	[self updateSearbarButtons:_keyword];
	[_searchBar resignFirstResponder];
	_searchBar.text = @"";
}

- (void)inputKeyboardWillShow:(NSNotification *)notification
{
	CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
	
	[UIView animateWithDuration:animationTime animations:^{
		CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
		_tableView.frame = CGRectMake(0, 0, SCREENWIT, SCREENHEI - 64 - keyBoardFrame.size.height);
	}];
}

@end
