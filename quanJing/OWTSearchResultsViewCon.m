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
#import "MobClick.h"
#import "LJSearchCell.h"
static NSString * kWaterFlowCellID = @"kWaterFlowCellID";

@interface OWTSearchResultsViewCon ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,NSURLConnectionDataDelegate,NSURLConnectionDelegate>
{
	OWTTabBarHider * _tabBarHider;
	UIImageView * _imageView1;
    UISearchBar *_searchBar;
    UITableView *_tableView;
    NSURLConnection *_connection;
    NSMutableData *_data;
    NSMutableArray *_dataArr;
    NSUserDefaults *_userDefault;
    BOOL isHistory;
    UIView *_footerView;

}

@property (nonatomic, strong) NSString * keyword;
@property (nonatomic, strong) NSMutableOrderedSet * assets;
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) OWaterFlowLayout * collectionViewLayout;

@end

@implementation OWTSearchResultsViewCon

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	if (self)
		_tabBarHider = [[OWTTabBarHider alloc] init];
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    [self setupCollectionView];
	[self setupRefreshControl];
	[self setUpBackView];
    [self setUpData];
    [self setUpFooterView];
    [self setUpTableView];
    [self setUpNavigation];
}
#pragma mark   合并历史记录
#pragma mark setUpView
-(void)setUpData
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    _data=[[NSMutableData alloc]init];
    _dataArr=[[NSMutableArray alloc]init];
    _userDefault=[NSUserDefaults standardUserDefaults];
}
-(void)setUpFooterView
{
    _footerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, 30)];
    _footerView.backgroundColor=[UIColor whiteColor];
    UILabel *clearLabel=[LJUIController createLabelWithFrame:CGRectMake(100, 0, 200, 30) Font:14 Text:@"清除历史纪录"];
    clearLabel.textColor=[UIColor blackColor];
    clearLabel.userInteractionEnabled=YES;
    [_footerView addSubview:clearLabel];
    UILabel *line=[LJUIController createLabelWithFrame:CGRectMake(0, 29.8, SCREENWIT, 0.2) Font:12 Text:nil];
    line.backgroundColor=[UIColor blackColor];
    [_footerView addSubview:line];
    [_footerView addSubview:clearLabel];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clearHistory)];
    [_footerView addGestureRecognizer:tap];
}
-(void)setUpNavigation
{
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 20, SCREENWIT, 44)];
    //    view.backgroundColor=[UIColor blackColor];
    [self SetUpsearchView];
    [view addSubview:_searchBar];
    view.tag=222;
    UIButton *cancel=[LJUIController createButtonWithFrame:CGRectMake(SCREENWIT-50, 2, 50, 40) imageName:nil title:@"取消" target:self action:@selector(cancelClick)];
    [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [view addSubview:cancel];
    [self.navigationController.view addSubview:view];
}
-(void)SetUpsearchView
{
    //self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:23/255.0f green:200/255.0f  blue:184/255.0f alpha:1.0f];
    _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 2, SCREENWIT-50, 40)];
    _searchBar.delegate=self;
    _searchBar.placeholder=@"搜图片";
    _searchBar.userInteractionEnabled=YES;
    _searchBar.translucent = NO;
    _searchBar.tintColor=[UIColor lightGrayColor];
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
//    [_searchBar becomeFirstResponder];
    [_searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"SearchBarBG"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)]
                                     forState:UIControlStateNormal];
    [_searchBar.layer setBorderColor:[UIColor redColor].CGColor];
    
}
-(void)setUpTableView
{
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, SCREENHEI-64-5) style:UITableViewStyleGrouped];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    [self.view addSubview:_tableView];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.backgroundColor=[UIColor whiteColor];
}
#pragma mark 合并事件
- (void)setUpBackView
{
	_imageView1 = [LJUIController createImageViewWithFrame:CGRectMake(0, 0, 100, 100) imageName:@"seach"];
	//    _imageView1.backgroundColor=[UIColor blackColor];
	_imageView1.hidden = YES;
	//    _imageView1.center=self.view.center;
	_imageView1.center = CGPointMake(self.view.center.x, self.view.center.y - 50);
	[self.view addSubview:_imageView1];
}
#pragma mark 请求数据
-(void)getImageData:(NSString *)searchText
{
    
    NSString *urlString=[NSString stringWithFormat:@"http://api.tiankong.com/qjapi/searchtip/%@",searchText];
    NSString* encodedString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:encodedString]];
    _connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [_data setLength:0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (_data.length==0) {
        return;
    }
    NSArray *arr=[NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableContainers error:nil];
    [_dataArr removeAllObjects];
    if (arr.count!=1) {
        [_dataArr addObjectsFromArray:arr];
    }
    isHistory=NO;
    [_tableView reloadData];
}
#pragma mark tableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (isHistory&&_dataArr.count>0) {
        return _footerView;
    }
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (isHistory) {
        return 30;
    }
    return 0;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"LJSearchCell";
    LJSearchCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[NSBundle mainBundle] loadNibNamed:@"LJSearchCell" owner:self options:nil][0];
    }
    cell.searchLabel.text=_dataArr[indexPath.row];
    
    if (isHistory) {
        cell.searchImage.image=[UIImage imageNamed:@"搜索1_03.png"];
    }else{
        cell.searchImage.image=[UIImage imageNamed:@"搜索2_03.png"];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}
#pragma mark tapAndClick
-(void)getUpHistoryData
{
    [_dataArr removeAllObjects];
    NSArray *arr=[_userDefault arrayForKey:@"searchHistory"];
    [_dataArr addObjectsFromArray:arr];
    isHistory=YES;
    [_tableView reloadData];
}
-(void)clearHistory
{
    [_userDefault removeObjectForKey:@"searchHistory"];
    [_userDefault synchronize];
    [self getUpHistoryData];
}
-(void)cancelClick
{
    for (UIView *view in self.navigationController.view.subviews) {
        if (view.tag==222) {
            [view removeFromSuperview];
        }
    }
    [self.navigationController popViewControllerAnimated:NO];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr=[_userDefault arrayForKey:@"searchHistory"];
    NSMutableArray *arr1=[[NSMutableArray alloc]initWithArray:arr];
    NSInteger number=0;
    for (NSString *searchStr in arr1) {
        if ([searchStr isEqualToString:_dataArr[indexPath.row]]) {
            break;
        }
        number++;
    }
    if (number<arr1.count) {
        [arr1 removeObjectAtIndex:number];
    }
    if (arr1.count>=10) {
        [arr1 insertObject:_dataArr[indexPath.row] atIndex:0];
        [arr1 removeLastObject];
    }else {
        [arr1 insertObject:_dataArr[indexPath.row] atIndex:0];
    }
    [_userDefault setObject:arr1 forKey:@"searchHistory"];
    [_userDefault synchronize];
//    [self performSearch:_dataArr[indexPath.row]];
    [_searchBar resignFirstResponder];
    _searchBar.text = @"";
    for (UIView *view in self.navigationController.view.subviews) {
        if (view.tag==222) {
            view.hidden=YES;
        }
    }
    
}
-(void)inputKeyboardWillShow:(NSNotification *)notification
{
    CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animationTime animations:^{
        CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        _tableView.frame=CGRectMake(0, 0, SCREENWIT, SCREENHEI-64-keyBoardFrame.size.height);
    }];
    
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
	__weak OWTSearchResultsViewCon * wself = self;
	
	[_collectionView addInfiniteScrollingWithActionHandler:^{[wself loadMoreData]; }];
}

- (void)dealloc
{
	[SVProgressHUD dismiss];
	_collectionView.delegate = nil;
	_collectionView.dataSource = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[MobClick beginEvent:@"搜索"];
    for (UIView *view in self.navigationController.view.subviews) {
        if (view.tag==222) {
            view.hidden=NO;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[SVProgressHUD dismiss];
	[MobClick endEvent:@"搜索"];
}

- (void)setKeyword:(NSString *)keyword
{
	[SVProgressHUD show];
	_keyword = [keyword copy];
	_assets = [[NSMutableOrderedSet alloc]init];
	[self loadMoreData];
	[_collectionView setContentOffset:CGPointMake(0, -self.collectionView.contentInset.top) animated:YES];
}

- (void)setKeyword:(NSString *)keyword withAssets:(NSArray *)assets
{
	_keyword = [keyword copy];
	if (assets && (assets.count > 0))
		_assets = [NSMutableOrderedSet orderedSetWithArray:assets];
	else
		_assets = nil;
	[self.collectionView reloadData];
	[_collectionView setContentOffset:CGPointMake(0, -self.collectionView.contentInset.top) animated:YES];
}

- (void)mergeAssets:(NSArray *)assets
{
	[_assets addObjectsFromArray:assets];
	[_collectionView reloadData];
}

- (void)loadMoreData
{
	QJInterfaceManager * fm = [QJInterfaceManager sharedManager];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[fm requestImageSearchKey:_keyword pageNum:_assets.count / 50 + 1 pageSize:50 currentImageId:nil finished:^(NSArray * imageObjectArray, NSArray * resultArray, NSError * error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (error) {
					[SVProgressHUD showError:error];
					return;
				}
				
				if (imageObjectArray.count == 0) {
					if (_assets.count == 0)
						_imageView1.hidden = NO;
				}
				else {
					_imageView1.hidden = YES;
				}
				[_collectionView.infiniteScrollingView stopAnimating];
				[SVProgressHUD dismiss];
				
				if (imageObjectArray && (imageObjectArray.count > 0))
					[self mergeAssets:imageObjectArray];
			});
		}];
	});
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
    [self.view sendSubviewToBack:_tableView];
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
	
	if (model != nil) {
		model.imageType = [NSNumber numberWithInt:1];
		OWTAssetViewCon * assetViewCon = [[OWTAssetViewCon alloc]initWithImageId:model imageType:model.imageType];
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
