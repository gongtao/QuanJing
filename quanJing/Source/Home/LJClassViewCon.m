//
//  LJClassViewCon.m
//  Weitu
//
//  Created by qj-app on 15/8/19.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJClassViewCon.h"
#import "ASIHTTPRequest.h"
#import "LJCategory.h"
#import "LJClassTableViewCell.h"
#import "OWTSearchResultsViewCon.h"
#import "UIColor+HexString.h"
#import "QuanJingSDK.h"
#import <UIImageView+WebCache.h>
#import "MobClick.h"
@interface LJClassViewCon () <UITableViewDelegate, UITableViewDataSource, ASIHTTPRequestDelegate, UISearchBarDelegate>

@end

@implementation LJClassViewCon
{
	UITableView * _tableView;
	NSMutableArray * _dataArr;
	UISearchBar * _searchBar;
}
- (void)viewDidLoad
{
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];
	_dataArr = [[NSMutableArray alloc]init];
	[self setUpTableView];
	[self getData];
}

- (void)viewWillAppear:(BOOL)animated
{
	[self setupNavigationBarColor];
}

- (void)setupNavigationBarColor
{
	//    self.navigationController.navigationBar.barTintColor = nil;
	//    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:GetThemer().themeTintColor forKey:UITextAttributeTextColor];
	//    UIApplication *application = [UIApplication sharedApplication];
	//    [application setStatusBarStyle:UIStatusBarStyleDefault];
}

#pragma mark getData
- (void)getData
{
	QJInterfaceManager * fm = [QJInterfaceManager sharedManager];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[fm requestImageRootCategory:^(NSArray * _Nonnull imageCategoryArray, NSArray * _Nonnull resultArray, NSError * _Nonnull error) {
			
			dispatch_async(dispatch_get_main_queue(), ^{
                [_dataArr addObjectsFromArray:imageCategoryArray];
				[_tableView reloadData];
			});
		}];
	});
}

#pragma mark setUpTableView
- (void)setUpTableView
{
	self.title = @"分类";
	_searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, 40)];
	_searchBar.delegate = self;
	_searchBar.placeholder = @"搜图片";
	_searchBar.translucent = NO;
	_searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.tintColor=[UIColor lightGrayColor];
	[_searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"SearchBarBG"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)]
	forState:UIControlStateNormal];
	[self changeSearchBarBackcolor:_searchBar];
	[self.view addSubview:_searchBar];
	UILabel * label = [LJUIController createLabelWithFrame:CGRectMake(0, 39, SCREENWIT, 0.3) Font:12 Text:nil];
	label.backgroundColor = [UIColor grayColor];
	[self.view addSubview:label];
	_tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 40, SCREENWIT, SCREENHEI - 64 - 40)];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];
}

- (void)changeSearchBarBackcolor:(UISearchBar *)mySearchBar
{
	float version = [[[UIDevice currentDevice] systemVersion] floatValue];
	
	if ([mySearchBar respondsToSelector:@selector(barTintColor)]) {
		float iosversion7_1 = 7.1;
		
		if (version >= iosversion7_1) {
			[[[[mySearchBar.subviews objectAtIndex:0] subviews] objectAtIndex:0] removeFromSuperview];
			[mySearchBar setBackgroundColor:[UIColor clearColor]];
			//                        [ mySearchBar setBackgroundColor :[ UIColor colorWithHexString:@"#f0f1f3"]];
			//            [mySearchBar setBackgroundColor:[UIColor whiteColor]];
		}
		else {
			//            [ mySearchBar setBarTintColor :[ UIColor clearColor ]];
			[mySearchBar setBackgroundColor:[UIColor clearColor]];
			//                        [ mySearchBar setBackgroundColor :[ UIColor colorWithHexString:@"#f0f1f3"]];
			//            [mySearchBar setBackgroundColor:[UIColor whiteColor]];
		}
	}
	else {
		[[mySearchBar.subviews objectAtIndex:0] removeFromSuperview];
		[mySearchBar setBackgroundColor:[UIColor clearColor]];
		//                [ mySearchBar setBackgroundColor :[ UIColor colorWithHexString:@"#f0f1f3"]];
		//        [mySearchBar setBackgroundColor:[UIColor whiteColor]];
	}
	
	[_searchBar.layer setBorderColor:[UIColor redColor].CGColor];
}

#pragma mark searchBarDelegate
- (void)performSearch:(NSString *)keyword
{
	OWTSearchResultsViewCon * searchResultsViewCon = [[OWTSearchResultsViewCon alloc] initWithNibName:nil bundle:nil];
	
	searchResultsViewCon.view.tag = 8173;
	//    self.navigationController.navigationBar.barTintColor = nil;
	[searchResultsViewCon setKeyword:keyword];
	searchResultsViewCon.hidesBottomBarWhenPushed = YES;
	//    [searchResultsViewCon substituteNavigationBarBackItem];
	//    UIApplication *application = [UIApplication sharedApplication];
	//    [application setStatusBarStyle:UIStatusBarStyleDefault];
	[self.navigationController pushViewController:searchResultsViewCon animated:YES];
	_searchBar.text = nil;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[self performSearch:searchBar.text];
	[searchBar resignFirstResponder];
	searchBar.text = @"";
}

#pragma  mark tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString * identifier = @"LJClass";
	LJClassTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (!cell)
		cell = [[NSBundle mainBundle] loadNibNamed:@"LJClassTableViewCell" owner:self options:nil][0];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	QJImageCategory * model = _dataArr[indexPath.row];
	NSLog(@"%@", model.image);
	NSString * imageurl = [QJInterfaceManager thumbnailUrlFromImageUrl:model.image size:cell.headView.bounds.size];
	cell.headView.alpha = 0.0;
	__weak UIImageView * weakImageView = cell.headView;
	[cell.headView setImageWithURL:[NSURL URLWithString:imageurl]
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
	cell.nameLabel.text = model.name;
	cell.countLabel.text = model.imageCount.stringValue;
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	QJImageCategory * model = _dataArr[indexPath.row];
    NSDictionary *dict=@{@"title":model.name};
    [MobClick event:@"index_category" attributes:dict];

	[self performSearch:model.name];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

@end
