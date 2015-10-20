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
@interface LJClassViewCon ()<UITableViewDelegate,UITableViewDataSource,ASIHTTPRequestDelegate,UISearchBarDelegate>

@end

@implementation LJClassViewCon
{
    UITableView *_tableView;
    ASIHTTPRequest *_asi;
    NSMutableArray *_dataArr;
    UISearchBar *_searchBar;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    _dataArr=[[NSMutableArray alloc]init];
    [self setUpTableView];
    [self getData];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self setupNavigationBarColor];

}
-(void)setupNavigationBarColor
{
//    self.navigationController.navigationBar.barTintColor = nil;
//    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:GetThemer().themeTintColor forKey:UITextAttributeTextColor];
//    UIApplication *application = [UIApplication sharedApplication];
//    [application setStatusBarStyle:UIStatusBarStyleDefault];
}

#pragma mark getData
-(void)getData
{

    NSString *urlStr=@"http://api.tiankong.com/qjapi/cdn2/categories1";
    _asi=[[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:urlStr]];
    _asi.delegate=self;
    [_asi startAsynchronous];
}
-(void)requestFailed:(ASIHTTPRequest *)request
{
    [SVProgressHUD showErrorWithStatus:@"网络不好"];
}
-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:nil];
    for (NSDictionary *dict1 in dict[@"categories"]) {
        LJCategory *model=[[LJCategory alloc]init];
        model.categoryName=dict1[@"categoryName"];
        model.count=dict1[@"count"];
        model.searchWord=dict1[@"searchWord"];
        model.url=dict1[@"coverImageInfo"][@"url"];
        [_dataArr addObject:model];
    }
    [_tableView reloadData];
}
#pragma mark setUpTableView
-(void)setUpTableView
{
    self.title=@"分类";
    _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, 40)];
    _searchBar.delegate=self;
    _searchBar.placeholder=@"搜图片";
    _searchBar.translucent = NO;
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    [_searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"SearchBarBG"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)]
                                     forState:UIControlStateNormal];
    [self changeSearchBarBackcolor:_searchBar];
    [self.view addSubview:_searchBar];
    UILabel *label=[LJUIController createLabelWithFrame:CGRectMake(0, 39, SCREENWIT, 0.3) Font:12 Text:nil];
    label.backgroundColor=[UIColor grayColor];
    [self.view addSubview:label];
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 40, SCREENWIT, SCREENHEI-64-40)];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    [self.view addSubview:_tableView];

}
-(void)changeSearchBarBackcolor:(UISearchBar *)mySearchBar
{
    float version = [[[ UIDevice currentDevice ] systemVersion ] floatValue ];
    
    if ([ mySearchBar respondsToSelector : @selector (barTintColor)]) {
        
        float  iosversion7_1 = 7.1 ;
        
        if (version >= iosversion7_1)
            
        {
            [[[[ mySearchBar . subviews objectAtIndex : 0 ] subviews ] objectAtIndex : 0 ] removeFromSuperview ];
            [mySearchBar setBackgroundColor:[UIColor clearColor]];
//                        [ mySearchBar setBackgroundColor :[ UIColor colorWithHexString:@"#f0f1f3"]];
//            [mySearchBar setBackgroundColor:[UIColor whiteColor]];
        }
        else
        {
//            [ mySearchBar setBarTintColor :[ UIColor clearColor ]];
                        [mySearchBar setBackgroundColor:[UIColor clearColor]];
//                        [ mySearchBar setBackgroundColor :[ UIColor colorWithHexString:@"#f0f1f3"]];
//            [mySearchBar setBackgroundColor:[UIColor whiteColor]];
        }
    }
    else
    {
        [[ mySearchBar . subviews objectAtIndex : 0 ] removeFromSuperview ];
        [mySearchBar setBackgroundColor:[UIColor clearColor]];
//                [ mySearchBar setBackgroundColor :[ UIColor colorWithHexString:@"#f0f1f3"]];
//        [mySearchBar setBackgroundColor:[UIColor whiteColor]];
    }
    
    [_searchBar.layer setBorderColor:[UIColor redColor].CGColor];
}

#pragma mark searchBarDelegate
- (void)performSearch:(NSString *)keyword
{

    OWTSearchResultsViewCon* searchResultsViewCon = [[OWTSearchResultsViewCon alloc] initWithNibName:nil bundle:nil];
    searchResultsViewCon.view.tag = 8173;
//    self.navigationController.navigationBar.barTintColor = nil;
    [searchResultsViewCon setKeyword:keyword ];
    searchResultsViewCon.hidesBottomBarWhenPushed = YES;
    [searchResultsViewCon substituteNavigationBarBackItem];
//    UIApplication *application = [UIApplication sharedApplication];
//    [application setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController pushViewController:searchResultsViewCon animated:YES];
    _searchBar.text = nil;
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self performSearch:searchBar.text];
    [searchBar resignFirstResponder];
    searchBar.text=@"";
}
#pragma  mark tableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *identifier=@"LJClass";
    LJClassTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[NSBundle mainBundle] loadNibNamed:@"LJClassTableViewCell" owner:self options:nil][0];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    LJCategory *model=_dataArr[indexPath.row];
    [cell.headView setImageWithURL:[NSURL URLWithString:model.url]];
    cell.nameLabel.text=model.categoryName;
    cell.countLabel.text=model.count;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LJCategory *model=_dataArr[indexPath.row];
    [self performSearch:model.searchWord];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
