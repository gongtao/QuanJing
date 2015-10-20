//
//  OQJCategoryViewCon.m
//  Weitu
//
//  Created by Su on 8/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OQJExploreViewCon.h"
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
#import "LJCoreData1.h"
#import "OQJExploreViewCon1.h"
#import "LJHuancunModel.h"
#import "OWTUserManager.h"
#import "NetStatusMonitor.h"
#import "UIColor+HexString.h"
static NSString* kCategoryCellID = @"kCategoryCellID";
static const int kDefaultLoadItemNum1 = 10;
@interface OQJExploreViewCon ()<ASIHTTPRequestDelegate,UIScrollViewDelegate>
{
    //    NSMutableArray *showArr;
    NSArray *arrAll;
    XHRefreshControl* _refreshControl;
    NSMutableArray *dataArr;
    LJCoreData1 *_coreData1;
    OWTUser *_user;
}

@property (nonatomic, strong) OWaterFlowLayout* waterFlowLayout;
@property (nonatomic, strong) XHRefreshControl* refreshControl;
@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, copy) NSMutableArray* categories;
@property (nonatomic, copy)NSArray *seArr;
@property (nonatomic, copy)NSArray *titleArr;
@property (nonatomic, copy)NSArray *titleArr1;
@property (nonatomic, strong) JCTopic* Topic;
@property (nonatomic, strong)  UILabel *label1;
@property (strong, nonatomic)  UILabel *label2;
@property (strong, nonatomic)  UIPageControl *page;
@property (nonatomic, assign) NSInteger pageCount;
//@property (strong, nonatomic)  SHPage *pageN;
@property (nonatomic, strong) OWTCategoryListViewCon* categoryListViewCon;
@end
@implementation OQJExploreViewCon
{
    BOOL isFirst;
    UIScrollView *_scrollView;
    NSMutableArray *_categories1;
    NSMutableArray *_categories2;
    NSMutableArray *_categories3;
    NSMutableArray *_categories4;
    NSMutableArray *_categories5;
    NSMutableArray *_categories6;
    NSMutableArray *pages;
    NSArray *_arr;
    UITableView *currentTableView;
    UIView *_view;
}
- (instancetype)initWithPage:(NSInteger)page
{
    self = [super init];
    if (self) {
        _pageCount=page;
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _pageCount=_pCount;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    _categories1=[[NSMutableArray alloc]init];
    _categories2=[[NSMutableArray alloc]init];
    _categories3=[[NSMutableArray alloc]init];
    _categories4=[[NSMutableArray alloc]init];
    _categories5=[[NSMutableArray alloc]init];
    _categories6=[[NSMutableArray alloc]init];
    pages=[[NSMutableArray alloc]init];
    for (NSInteger i=0; i<6; i++) {
        NSString *str=@"1";
        [pages addObject:str];
    }
    
    _titleArr1 =@[@"旅游",@"家居",@"汽车",@"美食",@"时尚",@"百科"];
    
    //    dataArr = [[NSMutableArray alloc]init];
    isFirst=YES;
    _categories = [[NSMutableArray alloc]init];
    _coreData1=[LJCoreData1 shareInstance];
    _user=GetUserManager().currentUser;
    [self setUpNavigationBar];
    [self setUpScrollView];
    [self setUpTabelView];
}
#pragma mark setUpView
-(void)setUpNavigationBar
{
    NSArray *arr=@[@"全部",@"旅游",@"家居",@"汽车",@"美食",@"时尚" ,@"百科"];
    _view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, 30)];
    _view.backgroundColor=[UIColor whiteColor];
    for (int i=0; i<7; i++) {
        UIButton *btn=[LJUIController createButtonWithFrame:CGRectMake(SCREENWIT/7*i, 0, SCREENWIT/7, 30) imageName:nil title:arr[i] target:self action:@selector(naviClick:)];
        btn.titleLabel.font=[UIFont systemFontOfSize:12];
        if (i==_pageCount) {
            self.title=arr[i];
            [btn setBackgroundImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
            [btn setTitleColor:GetThemer().themeTintColor forState:UIControlStateNormal];
        }else{
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
                btn.tag=300+i;
        [_view addSubview:btn];
        
    }
    [self.view addSubview:_view];
}
-(void)setUpScrollView
{
    _scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 30, SCREENWIT, SCREENHEI-64-30)];
    _scrollView.delegate=self;
    _scrollView.contentSize=CGSizeMake(SCREENWIT*6, SCREENHEI-64-30);
    _scrollView.pagingEnabled=YES;
    [self.view addSubview:_scrollView];
}
-(void)setUpTabelView
{
    for (NSInteger i=0; i<7; i++) {
  UITableView *  _tableView=[[UITableView alloc]initWithFrame:CGRectMake(SCREENWIT*i, 0, SCREENWIT, SCREENHEI-64-30)];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.tag=200+i;
//    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self setupRefreshWithTableView:_tableView];
    [_tableView registerNib:[UINib nibWithNibName:@"OWTCategoryTableViewCell" bundle:nil]
         forCellReuseIdentifier:kCategoryCellID];
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor whiteColor];
        [_scrollView addSubview:_tableView];
    }
    for (UIView *view in _scrollView.subviews) {
        if (view.tag==200+_pageCount) {
            currentTableView=(UITableView*)view;
        }
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (isFirst) {
        NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
        if (![user objectForKey:@"version2"]) {
            [_coreData1 deleteAll];
            [user setObject:@"dd" forKey:@"version2"];
        }
        LJHuancunModel *model=[_coreData1 check:@"find" withUserid:_user.userID];
        if (model) {
            NSDictionary *dic0 =[NSJSONSerialization JSONObjectWithData:model.response options:NSJSONReadingMutableLeaves error:nil];
            NSArray*appList=dic0[@"article"];
            for (NSDictionary*appdict in appList) {
                OWTexploreModel*model=[[OWTexploreModel alloc]init];
                for (NSString*key in appdict) {
                    NSLog(@"%@   %@",key,appdict[key]);
                    if ([appdict[key] isKindOfClass:[NSNull class]]) {
                        [model setValue:@"" forKey:key];
                    }else{
                        [model setValue:appdict[key] forKey:key];
                    
                    }
                }
                [_categories addObject:model];
            }
            _arr=_categories;
            }
        if (_arr.count>0) {
            [currentTableView reloadData];
            [currentTableView headerBeginRefreshing];
        }else
        {
            [currentTableView headerBeginRefreshing];
        }

    }
    isFirst=NO;
    [_scrollView setContentOffset:CGPointMake(SCREENWIT*_pageCount, 0)];
}


- (void)setupRefreshWithTableView:(UITableView *)tableView;
{
    tableView.allowsSelection = YES;
    UIImage* searchImage = [[FAKFontAwesome searchIconWithSize:22] imageWithSize:CGSizeMake(22, 22)];
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
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView==_scrollView) {
        _pageCount=scrollView.contentOffset.x/SCREENWIT;
        for (UIView *view in _scrollView.subviews) {
            if (view.tag==200+_pageCount) {
                currentTableView=(UITableView*)view;
            }
        }
        if (_pageCount==0) {
            _arr=_categories;
        }else if (_pageCount==1)
        {
            _arr=_categories1;
        }else if (_pageCount==2)
        {
            _arr=_categories2;
        }else if (_pageCount==3)
        {
            _arr=_categories3;
        }else if (_pageCount==4)
        {
            _arr=_categories4;
        }else if(_pageCount==5)
        {
            _arr=_categories5;
        }else {
        
            _arr=_categories6;
        }
//        [currentTableView headerBeginRefreshing];
        if (_arr.count==0) {
            [currentTableView headerBeginRefreshing];
        }else
        [currentTableView reloadData];
    }
    for (UIView *view in _view.subviews) {
        if (view.tag==300+_pageCount) {
            UIButton *btn=(UIButton *)view;
            [btn setBackgroundImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
            [btn setTitleColor:GetThemer().themeTintColor forState:UIControlStateNormal];
            self.title=btn.titleLabel.text;
        }else{
            UIButton *btn=(UIButton *)view;
            [btn setBackgroundImage:nil forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}
#pragma mark clickAndTap
-(void)naviClick:(UIButton *)sender
{
    NSInteger i=sender.tag-300;
    for (UIView *view in _view.subviews) {        
        if (view.tag==sender.tag) {
            UIButton *btn=(UIButton *)view;
           [btn setBackgroundImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
            [btn setTitleColor:GetThemer().themeTintColor forState:UIControlStateNormal];
        }else{
            UIButton *btn=(UIButton *)view;
            [btn setBackgroundImage:nil forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        }
            }
    [_scrollView setContentOffset:CGPointMake(SCREENWIT*i, 0) animated:YES];
    _pageCount=i;
    for (UIView *view in _scrollView.subviews) {
        if (view.tag==200+_pageCount) {
            currentTableView=(UITableView*)view;
        }
    }
    if (_pageCount==0) {
        _arr=_categories;
    }else if (_pageCount==1)
    {
        _arr=_categories1;
    }else if (_pageCount==2)
    {
        _arr=_categories2;
    }else if (_pageCount==3)
    {
        _arr=_categories3;
    }else if (_pageCount==4)
    {
        _arr=_categories4;
    }else if(_pageCount==5)
    {
        _arr=_categories5;
    }else
    {
        _arr=_categories6;
    }
    //        [currentTableView headerBeginRefreshing];
    if (_arr.count==0) {
        [currentTableView headerBeginRefreshing];
    }else{
        [currentTableView reloadData];
    [currentTableView headerBeginRefreshing];}


}
- (void)reloadData2
{
    NSString *page=pages[_pageCount];
    NSInteger page1=page.intValue;
    page1++;
    [pages replaceObjectAtIndex:_pageCount withObject:[NSString stringWithFormat:@"%ld",(long)page1]];
    NSString *str;
    NSInteger i;
        i=_pageCount;
    if (_pageCount==0) {
        i=10;
        str=[NSString stringWithFormat:@"http://api.tiankong.com/qjapi/cdn1/articleFound?count=%ld&page=%ld",(long)i,(long)page1];
    }else
    {
    str=[NSString stringWithFormat:@"http://api.tiankong.com/qjapi/cdn1/article?count=10&&type=%ld&page=%ld",(long)i,(long)page1];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSURL *url = [NSURL URLWithString:str];
        //利用三方解析json数据
        NSURLRequest *request =[NSURLRequest requestWithURL:url];
        NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        //NSJSONSerialization解析
        if (response!=nil) {
            NSDictionary *dic0 =[NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:nil];
            
            NSLog(@"dic0 =%@",dic0);
            if (response!=nil) {
                NSArray*appList=dic0[@"article"];
                for (NSDictionary*appdict in appList) {
                    OWTexploreModel*model=[[OWTexploreModel alloc]init];
                    for (NSString*key in appdict) {
                        if ([appdict[key] isKindOfClass:[NSNull class]]) {
                            // do something
                            [model setValue:@"" forKey:key];
                        }else{
                            //do something
                            [model setValue:appdict[key] forKey:key];
                        }
                    }
                    if (_pageCount==0) {
                        [_categories addObject:model];
                    }else if (_pageCount==1)
                    {
                        [_categories1 addObject:model];
                    }else if (_pageCount==2)
                    {
                        [_categories2 addObject:model];
                    }else if (_pageCount==3)
                    {
                        [_categories3 addObject:model];
                    }else if (_pageCount==4)
                    {
                        [_categories4 addObject:model];
                    }else if (_pageCount==5)
                    {
                        [_categories5 addObject:model];
                    }
                   else
                    {
                        [_categories6 addObject:model];
                    }
                }
            }
            [currentTableView reloadData];
        }
        [currentTableView footerEndRefreshing];
    });
}
-(void)reloadTableView
{
    if (_pageCount==0) {
        _arr=_categories;
    }else if (_pageCount==1)
    {
        _arr=_categories1;
    }else if (_pageCount==2)
    {
        _arr=_categories2;
    }else if (_pageCount==3)
    {
        _arr=_categories3;
    }else if (_pageCount==4)
    {
        _arr=_categories4;
    }else if(_pageCount==5)
    {
        _arr=_categories5;
    }else
    {
        _arr=_categories6;
    }
    [currentTableView reloadData];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

///要修改
- (void)refresh
{
    NSString *str;
    NSInteger i;
    if (_pageCount==0) {
        i=10;
        str=[NSString stringWithFormat:@"http://api.tiankong.com/qjapi/cdn1/articleFound?count=%ld&page=1",(long)i];
    }else{

        i=_pageCount;
        str=[NSString stringWithFormat:@"http://api.tiankong.com/qjapi/cdn1/article?count=10&&type=%ld&page=1",(long)i];
    
}
    NSURL *url = [NSURL URLWithString:str];
    ASIHTTPRequest *_asi=[[ASIHTTPRequest alloc]initWithURL:url];
    _asi.tag=12;
    _asi.delegate=self;
    [_asi startAsynchronous];
    
}
-(void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.tag==12) {
        if (![NetStatusMonitor isExistenceNetwork]) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
        }
        else{
            [SVProgressHUD showGeneralError];
        }
        [currentTableView headerEndRefreshing];
    }
    
}
-(void)requestFinished:(ASIHTTPRequest *)request
{
    if (request.tag==12) {
        if (_pageCount==0) {
            [_categories removeAllObjects];
        }else if (_pageCount==1)
        {
            [_categories1 removeAllObjects];
        }else if (_pageCount==2)
        {
            [_categories2 removeAllObjects];
        }else if (_pageCount==3)
        {
            [_categories3 removeAllObjects];
        }else if (_pageCount==4)
        {
            [_categories4 removeAllObjects];
        }else if(_pageCount==5)
        {
            [_categories5 removeAllObjects];
        }else
        {
            [_categories6 removeAllObjects];
        }
        NSDictionary *dic0 =[NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableLeaves error:nil];
        if (_pageCount==0) {
            LJHuancunModel *model=[_coreData1 check:@"find" withUserid:_user.userID];
            if (model) {
                [_coreData1 update:@"find" with:request.responseData withUserid:_user.userID];
            }else {
                [_coreData1 insert:request.responseData withType:@"find" withUserId:_user.userID];}
        }
        NSArray*appList=dic0[@"article"];
        for (NSDictionary*appdict in appList) {
            OWTexploreModel*model=[[OWTexploreModel alloc]init];
            for (NSString*key in appdict) {
                if ([appdict[key] isKindOfClass:[NSNull class]]) {
                    // do something
                    [model setValue:@"" forKey:key];
                }else{
                    // do something
                    [model setValue:appdict[key] forKey:key];
                }
            }
            if (_pageCount==0) {
                [_categories addObject:model];
            }else if (_pageCount==1)
            {
                [_categories1 addObject:model];
            }else if (_pageCount==2)
            {
                [_categories2 addObject:model];
            }else if (_pageCount==3)
            {
                [_categories3 addObject:model];
            }else if (_pageCount==4)
            {
                [_categories4 addObject:model];
            }else if(_pageCount==5)
            {
                [_categories5 addObject:model];
            }else
            {
                [_categories6 addObject:model];
            }
        }
        //        NSString *homeDictory=NSHomeDirectory();
        //       NSString *homePath  = [homeDictory stringByAppendingString:@"/Documents/ddd.archiver"];//添加储存的文件名
        //        BOOL flag=[NSKeyedArchiver archiveRootObject:_categories toFile:homePath];
//        [currentTableView reloadData];
        [self reloadTableView];
        [currentTableView headerEndRefreshing];
        
    }
    
}
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView!=currentTableView) {
        return 0;
    }
    return _arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OWTCategoryTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCategoryCellID forIndexPath:indexPath];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    OWTexploreModel* category = _arr[indexPath.row];
    NSMutableString *urlStr=[[NSMutableString alloc]initWithString:category.CoverUrl];
    NSRange range=[urlStr rangeOfString:@"cover"];
    [urlStr replaceCharactersInRange:range withString:@"bigcover"];
    [cell.thumbImageV setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@""]];
    cell.SubtitleLabel.text = category.Caption;
    //    cell.SummaryLabel.text = category.Subtitle;
    cell.backgroundColor=[UIColor colorWithHexString:@"#ededed"];
    NSAttributedString *attributedString =[[NSAttributedString alloc] initWithString:category.Summary attributes:@{NSForegroundColorAttributeName : [UIColor darkGrayColor],NSKernAttributeName : @(1.3f)}];
    //
    [cell.SummaryLabel setAttributedText:attributedString];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 228;
}

#pragma mark - UICollectionViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    OWTexploreModel *category;
    if (_pageCount==0) {
        category=_categories[indexPath.row];
    }else if (_pageCount==1)
    {
        category=_categories1[indexPath.row];
            }else if (_pageCount==2)
    {
        category=_categories2[indexPath.row];
        
    }else if (_pageCount==3)
    {
        category=_categories3[indexPath.row];
        
    }else if (_pageCount==4)
    {
        category=_categories4[indexPath.row];
        
    }else
    {
        category=_categories5[indexPath.row];
            }

   
    WLJWebViewController *evc = [[WLJWebViewController alloc]init];
    
    //
    evc.SummaryStr =category.Summary;
    //    //
    evc.titleS=category.Caption;
    evc.urlString =category.Url;
    evc.assetUrl =category.CoverUrl;
    [self.navigationController pushViewController:evc animated:YES];
    [evc substituteNavigationBarBackItem];
}

#pragma mark - ScrollView Delegate




//
#pragma mark -





//
- (void)search
{
    OWTSearchViewCon* searchViewCon = [[OWTSearchViewCon alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:searchViewCon animated:YES];
}


@end
