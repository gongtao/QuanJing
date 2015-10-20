//
//  OQJCategoryViewCon.m
//  Weitu
//
//  Created by Su on 8/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OQJExploreViewCon1.h"

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


#import "OWTCategoryListViewCon.h"
#import "OWTexploreModel.h"
#import "MJRefresh.h"

static NSString* kCategoryCellID = @"kCategoryCellID";

static const int kDefaultLoadItemNum1 = 10;




@interface OQJExploreViewCon1 ()
{
    //    NSMutableArray *showArr;
    NSArray *arrAll;
    XHRefreshControl* _refreshControl;
    NSMutableArray *dataArr;
}

@property (nonatomic, strong) OWaterFlowLayout* waterFlowLayout;
@property (nonatomic, strong) XHRefreshControl* refreshControl;
@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, copy) NSMutableArray* categories;
@property (nonatomic, copy)NSArray *seArr;

@property (nonatomic, copy)NSArray *titleArr;

@property (nonatomic, strong) UIButton* Topic;
@property (nonatomic, strong)  UILabel *label1;
@property (strong, nonatomic)  UILabel *label2;
@property (strong, nonatomic)  UIPageControl *page;

@property (nonatomic, assign) NSInteger pageCount;
//@property (strong, nonatomic)  SHPage *pageN;
@property (nonatomic, strong) OWTCategoryListViewCon* categoryListViewCon;
@end

@implementation OQJExploreViewCon1

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self.tableView registerNib:[UINib nibWithNibName:@"OWTCategoryTableViewCell" bundle:nil]
             forCellReuseIdentifier:kCategoryCellID];
        self.tableView.backgroundColor = [UIColor whiteColor];
        
//        _refreshControl = [[XHRefreshControl alloc] initWithScrollView:self.tableView delegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
//    self.title =_title;
    
    _pageCount=2;
    
    
    
//    dataArr = [[NSMutableArray alloc]init];
    [self setUpTabelView];
    _categories = [[NSMutableArray alloc]init];
    [self setupNavigationBar];
    [self setupCollectionView];
    //    [self setupRefreshControl];
    //
    //   [self reloadData];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)setupNavigationBar
{

}
-(void)setUpTabelView
{
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, self.view.bounds.size.height-42-64)];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    [self.view addSubview:_tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"OWTCategoryTableViewCell" bundle:nil]
         forCellReuseIdentifier:kCategoryCellID];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    
}
- (void)setupCollectionView
{
    
    self.tableView.allowsSelection = YES;
    //添加jctopic
    
    //实例化
    _Topic = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 175)];
    //代理
    
    [_Topic addTarget:self action:@selector(changePage)forControlEvents:UIControlEventTouchUpInside];
//    
    
    UIImage* searchImage = [[FAKFontAwesome searchIconWithSize:22] imageWithSize:CGSizeMake(22, 22)];
    searchImage = [searchImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:searchImage
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(search)];
    
    [self.tableView addHeaderWithTarget:self action:@selector(refresh) dateKey:@"table"];
    
    [self.tableView headerBeginRefreshing];
    
    
    [self.tableView addFooterWithTarget:self action:@selector(reloadData1)];
      self.tableView.headerPullToRefreshText = @" ";
    
    self.tableView.headerReleaseToRefreshText = @" ";
    
    self.tableView.headerRefreshingText = @" ";
    
    
    
    self.tableView.footerPullToRefreshText = @" ";
    
    self.tableView.footerReleaseToRefreshText = @" ";
    
    self.tableView.footerRefreshingText = @" ";
    
    
    
    self.tableView.allowsSelection = YES;
    

    
}

-(BOOL) navigationShouldPopOnBackButton 
{
    UIApplication *application = [UIApplication sharedApplication];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
//    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
//    self.navigationController.navigationBar.barTintColor = GetThemer().homePageColor;
    [self.navigationController popViewControllerAnimated:YES];
    return YES;

}


-(void)currentPage:(int)page total:(NSUInteger)total{
    _label1.text = [NSString stringWithFormat:@"图片 Page %d",page+1];
    _page.numberOfPages = total;
    _page.currentPage = page;
}
-(void)changePage
{
    OWTexploreModel* category = _categories[0];
   WLJWebViewController *evc = [[WLJWebViewController alloc]init];
    
    evc.titleS=category.Caption;
    evc.urlString =category.Url;
    
    [self.navigationController pushViewController:evc animated:YES];
    [evc substituteNavigationBarBackItem];

}
-(void)didClick:(id)data{
   
    exploreViewController *evc = [[exploreViewController alloc]init];
    if (_page.currentPage==2||_page.currentPage==4) {
        evc.titleCount =6-_page.currentPage;
        evc.sortArr =arrAll[6-_page.currentPage];
        evc.titleArray =_titleArr[6-_page.currentPage];
    }
    else{
        evc.titleCount =_page.currentPage;
        evc.sortArr =arrAll[_page.currentPage];
        evc.titleArray =_titleArr[_page.currentPage];
    }
    [self.navigationController pushViewController:evc animated:YES];
    
    //写点击事件
    
}


//
- (void)reloadData1
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.tiankong.com/qjapi/cdn1/article?count=10&&type=%d&page=%d",_classCount,_pageCount]];
    
    _pageCount++;
    
    //利用三方解析json数据
    
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    //NSJSONSerialization解析
    if (response!=nil) {
    NSDictionary *dic0 =[NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:nil];
    
//    NSLog(@"dic0 =%@",dic0);
    
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
            
            [_categories addObject:model];
            
            
            
                  }
        
        
    }
    
    
    
    [self.tableView reloadData];
        [self.tableView footerEndRefreshing];});
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

///要修改
- (void)refresh
{
    
    
//    NSLog(@"///////////////%d",_classCount);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.tiankong.com/qjapi/cdn1/article?count=10&&type=%d&page=1",_classCount]];
    
    
    
    //利用三方解析json数据
    
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    //NSJSONSerialization解析
    if (response!=nil) {
    NSDictionary *dic0 =[NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:nil];
    
//    NSLog(@"dic0 =%@",dic0);
    
        NSArray*appList=dic0[@"article"];
        if (![appList isKindOfClass:[NSNull class]]) {
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
                
                [_categories addObject:model];
                
                
                
            }

        }
        else
            [SVProgressHUD showErrorWithStatus:@"没有了"];
        
        
}
    
    
    
    
    
    
    
    
    
    [self.tableView reloadData];
    [self.tableView headerEndRefreshing];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _categories.count-1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        OWTCategoryTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:kCategoryCellID forIndexPath:indexPath];
    
    OWTexploreModel* category1 = _categories[0];
    
    
    UIImageView *imV =[[UIImageView alloc]init];
    [imV setImageWithURL:[NSURL URLWithString:category1.CoverUrl ] placeholderImage:[UIImage imageNamed:@""]];
    [_Topic setBackgroundImage:imV.image forState:UIControlStateNormal];

    OWTexploreModel* category = _categories[indexPath.row];
    
    
    [cell.thumbImageV setImageWithURL:[NSURL URLWithString:category.CoverUrl ] placeholderImage:[UIImage imageNamed:@""]];
    cell.SubtitleLabel.text = category.Caption;
    //    cell.SummaryLabel.text = category.Subtitle;
    
       NSAttributedString *attributedString =[[NSAttributedString alloc] initWithString:category.Summary attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor],NSKernAttributeName : @(1.3f)}];
//    
    [cell.SummaryLabel setAttributedText:attributedString];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 227;
}

#pragma mark - UICollectionViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    NSLog(@"[[[[[[[[[[[[[[[[[[");
    OWTexploreModel* category = _categories[indexPath.row];
    WLJWebViewController *evc = [[WLJWebViewController alloc]init];
    
    evc.titleS=category.Caption;
    evc.urlString =category.Url;
    evc.SummaryStr =category.Summary;
    
    evc.assetUrl =category.CoverUrl;
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
    OWTSearchViewCon* searchViewCon = [[OWTSearchViewCon alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:searchViewCon animated:YES];
}


@end
