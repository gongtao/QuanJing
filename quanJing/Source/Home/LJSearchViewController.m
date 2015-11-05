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
@interface LJSearchViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,NSURLConnectionDataDelegate>

@end

@implementation LJSearchViewController
{
    UISearchBar *_searchBar;
    UITableView *_tableView;
    NSURLConnection *_connection;
    NSMutableData *_data;
    NSMutableArray *_dataArr;
    NSUserDefaults *_userDefault;
    BOOL isHistory;
    UIView *_footerView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpData];
    [self setUpFooterView];
    [self setUpNavigation];
    [self setUpTableView];
}
-(void)viewWillAppear:(BOOL)animated
{
    for (UIView *view in self.navigationController.view.subviews) {
        if (view.tag==111) {
            view.hidden=NO;
        }
    }
    if (_searchBar) {
        [_searchBar becomeFirstResponder];
    }
    [self getUpHistoryData];
}
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
    view.tag=111;
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
    [_searchBar becomeFirstResponder];
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
-(void)getUpHistoryData
{
    [_dataArr removeAllObjects];
    NSArray *arr=[_userDefault arrayForKey:@"searchHistory"];
    [_dataArr addObjectsFromArray:arr];
    isHistory=YES;
    [_tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark searchBarDelegate
- (void)performSearch:(NSString *)keyword
{
    OWTSearchResultsViewCon* searchResultsViewCon = [[OWTSearchResultsViewCon alloc] initWithNibName:nil bundle:nil];
    searchResultsViewCon.view.tag = 8173;
//    self.navigationController.navigationBar.barTintColor = nil;
    [searchResultsViewCon setKeyword:keyword ];
    searchResultsViewCon.hidesBottomBarWhenPushed = YES;
//    [searchResultsViewCon substituteNavigationBarBackItem];
//    UIApplication *application = [UIApplication sharedApplication];
//    [application setStatusBarStyle:UIStatusBarStyleDefault];
    
    [self.navigationController pushViewController:searchResultsViewCon animated:YES];
    _searchBar.text = nil;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                    // called when
{
    NSArray *arr=[_userDefault arrayForKey:@"searchHistory"];
    NSMutableArray *arr1=[[NSMutableArray alloc]initWithArray:arr];
    NSInteger number=0;
    for (NSString *searchStr in arr1) {
        if ([searchStr isEqualToString:searchBar.text]) {
            break;
        }
    number++;
    }
    if (number<arr1.count) {
        [arr1 removeObjectAtIndex:number];
    }
    if (arr1.count>=10) {
        [arr1 insertObject:searchBar.text atIndex:0];
        [arr1 removeLastObject];
    }else {
        [arr1 insertObject:searchBar.text atIndex:0];
    }
    [_userDefault setObject:arr1 forKey:@"searchHistory"];
    [_userDefault synchronize];
    [self performSearch:searchBar.text];
    [_searchBar resignFirstResponder];
    _searchBar.text = @"";
    for (UIView *view in self.navigationController.view.subviews) {
        if (view.tag==111) {
            view.hidden=YES;
        }
    }
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length>0) {
     [self getImageData:searchText];   
    }
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
-(void)clearHistory
{
    [_userDefault removeObjectForKey:@"searchHistory"];
    [_userDefault synchronize];
    [self getUpHistoryData];
}
-(void)cancelClick
{
    for (UIView *view in self.navigationController.view.subviews) {
        if (view.tag==111) {
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
    [self performSearch:_dataArr[indexPath.row]];
    [_searchBar resignFirstResponder];
    _searchBar.text = @"";
    for (UIView *view in self.navigationController.view.subviews) {
        if (view.tag==111) {
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

@end
