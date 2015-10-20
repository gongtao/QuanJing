//
//  LJExploreViewController.m
//  Weitu
//
//  Created by qj-app on 15/9/1.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJExploreViewController.h"
#import "MJRefresh.h"
#import "LJGameModel.h"
#import "LJHomeVIewCellTableViewCell.h"
#import "OWTTabBarHider.h"
#import "LJExploreSquareController.h"
#import "OWTAuthManager.h"
@interface LJExploreViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation LJExploreViewController
{
    UITableView *_tableView;
    NSMutableData *_data;
    NSMutableArray *_gameArr;
    OWTTabBarHider *_tabBarHider;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"活动";
    [self setUpData];
    [self setUpTableView];
    [self getSaveData];
}
-(void)getSaveData
{
    NSString *homeDictionary = NSHomeDirectory();//获取根目录
    NSString *homePath  = [homeDictionary stringByAppendingString:@"/Documents/game.archiver"];//添加储存的文件名
    NSArray *Arr=[NSKeyedUnarchiver unarchiveObjectWithFile:homePath];
    if (Arr==nil) {
        return;
    }
    for (NSDictionary*appdict in Arr) {
        LJGameModel *model=[[LJGameModel alloc]init];
        [model setValuesForKeysWithDictionary:appdict];
        [_gameArr addObject:model];
    }
    [self reloadTableView];
}
-(void)viewWillAppear:(BOOL)animated
{

    [_tabBarHider showTabBar];
}
-(void)setUpData
{
    _data=[[NSMutableData alloc]init];
    _gameArr=[[NSMutableArray alloc]init];
    _tabBarHider=[[OWTTabBarHider alloc]init];
}
-(void)setUpTableView
{
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, SCREENHEI-64-42) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    [self.view addSubview:_tableView];
    [_tableView addHeaderWithTarget:self action:@selector(getData) dateKey:@"table"];
    [_tableView headerBeginRefreshing];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    //    [_tableView addFooterWithTarget:self action:@selector(loadMoreFeedItems)];
    //一些设置
    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
    _tableView.headerPullToRefreshText = @"";
    _tableView.headerReleaseToRefreshText = @"";
    _tableView.headerRefreshingText = @"";
    
    _tableView.footerPullToRefreshText = @"";
    _tableView.footerReleaseToRefreshText = @"";
    _tableView.footerRefreshingText = @"";
}
-(void)reloadTableView
{
    [_tableView reloadData];
}
#pragma mark getData
-(void)getData
{
    NSURL *url = [NSURL URLWithString:@"http://api.tiankong.com/qjapi/game"];
    
    NSError *error;
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    
    NSURLConnection *connection=[NSURLConnection connectionWithRequest:request delegate:self];
    
    
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
    [_tableView headerEndRefreshing];
    [_gameArr removeAllObjects];
    NSDictionary *dict =[NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableLeaves error:nil];
    NSArray *Arr=dict[@"Game"];
    NSString *homeDictionary = NSHomeDirectory();//获取根目录
    NSString *homePath  = [homeDictionary stringByAppendingString:@"/Documents/game.archiver"];
    BOOL ret=[NSKeyedArchiver archiveRootObject:Arr toFile:homePath];
    for (NSDictionary*appdict in Arr) {
        LJGameModel *model=[[LJGameModel alloc]init];
        [model setValuesForKeysWithDictionary:appdict];
        [_gameArr addObject:model];
    }
    [self reloadTableView];
}

#pragma mark tableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _gameArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"LJHomeViewCell";
    LJHomeVIewCellTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[LJHomeVIewCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    LJGameModel *model=_gameArr[indexPath.row];
    [cell setImageWithUrl:model.GameCover];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float x=356;
    float y=640;
    CGFloat height=x/y*SCREENWIT;
    return height+5;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OWTAuthManager* am = GetAuthManager();
    if (!am.isAuthenticated)
    {
        [self showAuthViewCon];
    }
    else{

    LJGameModel *model=_gameArr[indexPath.row];
    LJExploreSquareController *lvc=[[LJExploreSquareController alloc]initWithGameId:model.GameId withTitle:model.GameTitle];
    lvc.hidesBottomBarWhenPushed=YES;
    [_tabBarHider hideTabBar];
        [self.navigationController pushViewController:lvc animated:YES];}
}
- (void)showAuthViewCon
    {
        OWTAuthManager* am = GetAuthManager();
        am.cancelBlock = ^{
            [self.navigationController popViewControllerAnimated:YES];
        };

        [am showAuthViewConWithSuccess:^{
        }
                                cancel:^{
//                                    OWTUserManager* um = GetUserManager();
                                    
                                }];
    }
@end
