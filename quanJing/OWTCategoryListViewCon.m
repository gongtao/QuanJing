//
//  OWTExploreCategoryViewCon.m
//  Weitu
//
//  Created by Su on 5/8/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTCategoryListViewCon.h"
#import "OWaterFlowLayout.h"
#import "OWaterFlowCollectionView.h"
#import "OWTTabBarHider.h"
#import "OWTCategoryManager.h"
#import "SVProgressHUD+WTError.h"
#import "UIView+EasyAutoLayout.h"
#import "OWTCategoryTableViewCell.h"
#import "OWTUserManager.h"
#import "OWTUserSubscriptionInfoData.h"
#import "OWTUser.h"
#import "OWTCategoryViewCon.h"
#import "OWTAuthManager.h"
#import <SIAlertView/SIAlertView.h>
#import <UISearchBar-Blocks/UISearchBar+Blocks.h>
#import "OWTAssetManager.h"
#import "OWTSearchManager.h"
#import "OWTSearchResultsViewCon.h"

#import "OWTexploreModel.h"


#import "WLJWebViewController.h"


#import "UIViewController+WTExt.h"
static NSString* kCategoryCellID = @"kCategoryCellID";

@interface OWTCategoryListViewCon ()
{
    OWTTabBarHider* _tabBarHider;
    XHRefreshControl* _refreshControl;
     NSMutableArray *dataArr;
}

@property (nonatomic, strong) UISearchBar* searchBar;
@property (nonatomic, copy) NSArray* categories;

@end

@implementation OWTCategoryListViewCon

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.view.backgroundColor = GetThemer().themeColorBackground;

    [self setupSearchBar];

    _tabBarHider = [[OWTTabBarHider alloc] init];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"OWTCategoryTableViewCell" bundle:nil]
         forCellReuseIdentifier:kCategoryCellID];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    _refreshControl = [[XHRefreshControl alloc] initWithScrollView:self.tableView delegate:self];
}

- (void)setupSearchBar
{
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 260, 44)];
    [_searchBar setPlaceholder:@"搜索"];
    _searchBar.delegate = self;
    _searchBar.translucent = NO;
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    [_searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"SearchBarBG"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)]
                                     forState:UIControlStateNormal];
    _searchBar.searchTextPositionAdjustment = UIOffsetMake(4, 1);
    _searchBar.searchFieldBackgroundPositionAdjustment = UIOffsetMake(0, 0);
    [_searchBar setPositionAdjustment:UIOffsetMake(0, 1) forSearchBarIcon:UISearchBarIconSearch];
    
    [self setupSearchBarActions];

    self.navigationItem.titleView = _searchBar;
}

- (void)setupSearchBarActions
{
    __weak OWTCategoryListViewCon* wself = self;

    [_searchBar setSearchBarCancelButtonClickedBlock:^(UISearchBar* searchBar){
        [wself.searchBar resignFirstResponder];
    }];

    [_searchBar setSearchBarSearchButtonClickedBlock:^(UISearchBar* searchBar) {
        [wself performSearch];
    }];

    [_searchBar setSearchBarShouldBeginEditingBlock:^BOOL(UISearchBar* searchBar) {
        [searchBar setShowsCancelButton:YES animated:YES];
        return YES;
    }];

    [_searchBar setSearchBarShouldEndEditingBlock:^BOOL(UISearchBar* searchBar) {
        [searchBar setShowsCancelButton:NO animated:YES];
        return YES;
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)dealloc
{
    _searchBar.delegate = nil;
}

- (void)reloadData
{
    dataArr = [[NSMutableArray alloc]init];
    
    NSURL *url = [NSURL URLWithString:@"http://api.tiankong.com/qjapi/cdn1/articleHome"];
    
    
    //利用三方解析json数据
    
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    //NSJSONSerialization解析
    
    NSDictionary *dic0 =[NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:nil];
    
//    NSLog(@"dic0 =%@",dic0);
    if (response!=nil) {
        NSArray*appList=dic0[@"article"];
        for (NSDictionary*appdict in appList) {
            
            
            
            OWTexploreModel*model=[[OWTexploreModel alloc]init];
            
            
            
            for (NSString*key in appdict) {
                
                
                
                [model setValue:appdict[key] forKey:key];
                
                
                
                
                
                
                
            }
            
            [dataArr addObject:model];
            
            
        }
        
        
    }
    
    
    NSLog(@"dddddddddddddddd%@",dataArr);

    
    
    _categories = dataArr;
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    OWTCategoryManager* cm = GetCategoryManager();
    if (cm.isRefreshNeeded)
    {
        [self manualRefresh];
    }
}

- (void)manualRefresh
{
    [_refreshControl startPullDownRefreshing];
}

- (void)refresh
{
    OWTCategoryManager* cm = GetCategoryManager();
    [cm refreshCategoriesWithSuccess:^{
        [_refreshControl endPullDownRefreshing];
        [self reloadData];
    }
                             failure:^(NSError* error) {
                                 [_refreshControl endPullDownRefreshing];
                                 [SVProgressHUD showError:error];
                             }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OWTCategoryTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:kCategoryCellID forIndexPath:indexPath];
    

    OWTexploreModel* category = _categories[indexPath.row];
    [cell.thumbImageV setImageWithURL:[NSURL URLWithString:category.CoverUrl ] placeholderImage:[UIImage imageNamed:@""]];
    cell.SubtitleLabel.text = category.Subtitle;

    
    NSAttributedString *attributedString =[[NSAttributedString alloc] initWithString:category.Summary attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor],NSKernAttributeName : @(1.3f)}];
    
    [cell.SummaryLabel setAttributedText:attributedString];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76;
}

#pragma mark - UICollectionViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OWTexploreModel* category = _categories[indexPath.row];
    WLJWebViewController *evc = [[WLJWebViewController alloc]init];
    
       evc.titleS=category.Caption;
        evc.urlString =category.Url;
    
    [self.navigationController pushViewController:evc animated:YES];
    [evc substituteNavigationBarBackItem];

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

#pragma mark - OWTCategoryCell Delegate

- (void)categoryCellSubscribeButtonPressed:(OWTCategoryTableViewCell*)categoryCell
{
    // TODO this part of code should be encapsulated as a function

}

#pragma mark - Searching

- (void)performSearch
{
    NSString* keyword = _searchBar.text;

    [SVProgressHUD showWithStatus:@"搜索中..." maskType:SVProgressHUDMaskTypeBlack];

    OWTSearchManager* sm = GetSearchManager();
    [sm searchAssetsWithKeyword:keyword
                        success:^(NSArray* assets) {
                            [_searchBar resignFirstResponder];
                            
                            [SVProgressHUD dismiss];

                            OWTSearchResultsViewCon* searchResultsViewCon = [[OWTSearchResultsViewCon alloc] initWithNibName:nil bundle:nil];
                            [searchResultsViewCon setKeyword:keyword withAssets:assets];
                            [self.navigationController pushViewController:searchResultsViewCon animated:YES];
                        }
                        failure:^(NSError* error) {
                            [SVProgressHUD showError:error];
                        }];
}

#pragma mark - 3rdparty refresh control

- (void)beginPullDownRefreshing
{
    [self refresh];
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
