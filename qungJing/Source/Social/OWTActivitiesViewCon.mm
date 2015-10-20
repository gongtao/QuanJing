//
//  OWTActivityListViewCon.m
//  Weitu
//
//  Created by Su on 6/3/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#ifndef ENABLE_CELLHEIGHT
#define ENABLE_CELLHEIGHT 1
#endif

#import "OWTActivitiesViewCon.h"
#import "UIView+EasyAutoLayout.h"
#import "OWTTabBarHider.h"
#import "SVProgressHUD+WTError.h"

#import "OWTActivityTableViewCell.h"
#import "OWTActivityManager.h"
#import "OWTMergedActivity.h"
#import "OWTAssetViewCon.h"
#import "OWTAssetManager.h"
#import "OWTUserManager.h"
#import "OWTUserViewCon.h"

#import "MJRefresh.h"

#import "AlbumPhotosListView.h"
#if ENABLE_CELLHEIGHT
#include <vector>
#endif

typedef enum
{
    nWTActivityCategoryFollowing = 0,
    nWTActivityCategoryFollower = 1,
    nWTActivityCategoryFriends = 2,
    nWTActivityCategoryMax = 3,
} EWTActivityCategory;

@interface OWTActivitiesViewCon ()
{
    XHRefreshControl* _refreshControl;

    EWTActivityCategory _displayingActivityCategory;
#if ENABLE_CELLHEIGHT
    std::vector<float> _cachedCellHeights[nWTActivityCategoryMax];
#endif
    NSArray* _activities[nWTActivityCategoryMax];
    CGFloat _cachedScrollPosition[nWTActivityCategoryMax];

    OWTActivityTableViewCell* _dummyTableViewCell;

    OWTTabBarHider* _tabBarHider;
    int _page;
}

@end

@implementation OWTActivitiesViewCon

- (instancetype)initWithDefaultStyle
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        _tabBarHider = [[OWTTabBarHider alloc] init];
        for (int i = 0; i < nWTActivityCategoryMax; ++i)
        {
            _cachedScrollPosition[i] = 0;
            _activities[i] = nil;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _page =1;
    self.view.backgroundColor = [UIColor whiteColor];

    [self setupTableView];

    [self showFriendsView];
}

- (void)setupTableView
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor colorWithWhite:0.0 alpha:0.1];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 4, 0, 4);

    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 4)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 4)];

    [self.tableView registerNib:[UINib nibWithNibName:@"OWTActivityTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"OWTActivityTableViewCell"];

    _refreshControl = [[XHRefreshControl alloc] initWithScrollView:self.tableView delegate:self];

    self.tableView.allowsSelection = NO;

    NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"OWTActivityTableViewCell" owner:self options:nil];
    _dummyTableViewCell = [nibObjects objectAtIndex:0];
    _dummyTableViewCell.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary* parameters = @{ @"view" : _dummyTableViewCell };
    [_dummyTableViewCell addConstraint:[NSLayoutConstraint constraintWithExpressionFormat:@"view.width = 320" parameters:parameters]];
    
    
    
    
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    //    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
//    [self.tableView addHeaderWithTarget:self action:nil dateKey:@"table"];
//#warning 自动刷新(一进入程序就下拉刷新)
//    [self.tableView headerBeginRefreshing];
//    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
    self.tableView.headerPullToRefreshText = @"";
    self.tableView.headerReleaseToRefreshText = @"";
    self.tableView.headerRefreshingText = @"";
    
    self.tableView.footerPullToRefreshText = @"";
    self.tableView.footerReleaseToRefreshText = @"";
    self.tableView.footerRefreshingText = @"";
}
-(void)footerRereshing
{//这里的用处是让count=10，count=20，
    _page=_page+1;
    NSLog(@"88888888888%d",_page);
    [self refreshFollowingActivities];
    [self refreshFollowerActivities];
     [self refreshFriendActivities];
//    [self.tableView headerEndRefreshing];
    
    
    
    
    
    
}




//
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshIfNeeded];
}

- (void)refreshIfNeeded
{
    if (_displayingActivityCategory == nWTActivityCategoryFollowing)
    {
        if (_activities[nWTActivityCategoryFollowing] == nil)
        {
            [self refreshFollowingActivities];
        }
    }
    else if (_displayingActivityCategory == nWTActivityCategoryFollower)
    {
        if (_activities[nWTActivityCategoryFollower] == nil)
        {
            [self refreshFollowerActivities];
        }
    }
    else if (_displayingActivityCategory == nWTActivityCategoryFriends)
    {
        if (_activities[nWTActivityCategoryFriends] == nil)
        {
            [self refreshFriendActivities];
        }
    }
}

#pragma mark -

- (void)showFollowingsView
{
    if (_displayingActivityCategory != nWTActivityCategoryFollowing)
    {
        _cachedScrollPosition[_displayingActivityCategory] = self.tableView.contentOffset.y;
        _displayingActivityCategory = nWTActivityCategoryFollowing;
        [self.tableView reloadData];
        self.tableView.contentOffset = CGPointMake(0, _cachedScrollPosition[_displayingActivityCategory]);
    }
}

- (void)showFollowersView
{
    if (_displayingActivityCategory != nWTActivityCategoryFollower)
    {
        _cachedScrollPosition[_displayingActivityCategory] = self.tableView.contentOffset.y;
        _displayingActivityCategory = nWTActivityCategoryFollower;
        [self.tableView reloadData];
        self.tableView.contentOffset = CGPointMake(0, _cachedScrollPosition[_displayingActivityCategory]);
    }
}

- (void)showFriendsView
{
    if (_displayingActivityCategory != nWTActivityCategoryFriends)
    {
        _cachedScrollPosition[_displayingActivityCategory] = self.tableView.contentOffset.y;
        _displayingActivityCategory = nWTActivityCategoryFriends;
        [self.tableView reloadData];
        self.tableView.contentOffset = CGPointMake(0, _cachedScrollPosition[_displayingActivityCategory]);
    }
}

#pragma mark - 

- (void)manualRefresh
{
    [_refreshControl startPullDownRefreshing];
}

- (void)refresh
{
    if (_displayingActivityCategory == nWTActivityCategoryFollowing)
    {
        [self refreshFollowingActivities];
    }
    else if (_displayingActivityCategory == nWTActivityCategoryFollower)
    {
        [self refreshFollowerActivities];
    }
    else if (_displayingActivityCategory == nWTActivityCategoryFriends)
    {
        [self refreshFriendActivities];
    }
    else
    {
        AssertTR(false);
        [_refreshControl endPullDownRefreshing];
    }
}

- (void)refreshFollowingActivities
{
    OWTActivityManager* am = GetActivityManager();

    [am refreshWithSuccess:^(NSArray* mergedActivities) {
        if (_page==1) {
            [_refreshControl endPullDownRefreshing];
        }
        else{
            [self.tableView footerEndRefreshing];
        }
        _activities[nWTActivityCategoryFollowing] = mergedActivities;
#if ENABLE_CELLHEIGHT
        _cachedCellHeights[nWTActivityCategoryFollowing].clear();
        _cachedCellHeights[nWTActivityCategoryFollowing].resize(mergedActivities.count);
#endif
        [self.tableView reloadData];
    } failure:^(NSError* error) {
        [_refreshControl endPullDownRefreshing];
        [SVProgressHUD showError:error];
    }
     with:_page];
}

- (void)refreshFollowerActivities
{
    OWTActivityManager* am = GetActivityManager();

    [am refreshWithSuccess:^(NSArray* mergedActivities) {
        if (_page==1) {
            [_refreshControl endPullDownRefreshing];
        }
        else{
            [self.tableView footerEndRefreshing];
        }
        _activities[nWTActivityCategoryFollower] = mergedActivities;
#if ENABLE_CELLHEIGHT
        _cachedCellHeights[nWTActivityCategoryFollower].clear();
        _cachedCellHeights[nWTActivityCategoryFollower].resize(mergedActivities.count);
#endif
        [self.tableView reloadData];
    } failure:^(NSError* error) {
        [_refreshControl endPullDownRefreshing];
        [SVProgressHUD showError:error];
    }
     with:_page];
}

- (void)refreshFriendActivities
{
    OWTActivityManager* am = GetActivityManager();
    
    [am refreshWithSuccess:^(NSArray* mergedActivities) {
        if (_page==1) {
            [_refreshControl endPullDownRefreshing];
        }
        else{
            [self.tableView footerEndRefreshing];
        }
        _activities[nWTActivityCategoryFriends] = mergedActivities;//!!!!!!!!
#if ENABLE_CELLHEIGHT
        _cachedCellHeights[nWTActivityCategoryFriends].clear();
        _cachedCellHeights[nWTActivityCategoryFriends].resize(mergedActivities.count);
#endif
        [self.tableView reloadData];
    } failure:^(NSError* error) {
        [_refreshControl endPullDownRefreshing];
        [SVProgressHUD showError:error];
    }
     with:_page];
}
//

- (void)refreshFollowingActivitiesmore
{
    OWTActivityManager* am = GetActivityManager();
    
    [am loadMoreWithSuccess:^(NSArray* mergedActivities) {
        [_refreshControl endPullDownRefreshing];
        _activities[nWTActivityCategoryFollowing] = mergedActivities;
#if ENABLE_CELLHEIGHT
        _cachedCellHeights[nWTActivityCategoryFollowing].clear();
        _cachedCellHeights[nWTActivityCategoryFollowing].resize(mergedActivities.count);
#endif
        [self.tableView reloadData];
    } failure:^(NSError* error) {
        [_refreshControl endPullDownRefreshing];
        [SVProgressHUD showError:error];
    }];
}

- (void)refreshFollowerActivitiesmore
{
    OWTActivityManager* am = GetActivityManager();
    
    [am loadMoreWithSuccess:^(NSArray* mergedActivities) {
        [_refreshControl endPullDownRefreshing];
        _activities[nWTActivityCategoryFollower] = mergedActivities;
#if ENABLE_CELLHEIGHT
        _cachedCellHeights[nWTActivityCategoryFollower].clear();
        _cachedCellHeights[nWTActivityCategoryFollower].resize(mergedActivities.count);
#endif
        [self.tableView reloadData];
    } failure:^(NSError* error) {
        [_refreshControl endPullDownRefreshing];
        [SVProgressHUD showError:error];
    }];
}

- (void)refreshFriendActivitiesmore
{
    OWTActivityManager* am = GetActivityManager();
    
    [am loadMoreWithSuccess:^(NSArray* mergedActivities) {
        [_refreshControl endPullDownRefreshing];
        _activities[nWTActivityCategoryFriends] = mergedActivities;//!!!!!!!!
#if ENABLE_CELLHEIGHT
        _cachedCellHeights[nWTActivityCategoryFriends].clear();
        _cachedCellHeights[nWTActivityCategoryFriends].resize(mergedActivities.count);
#endif
        [self.tableView reloadData];
    } failure:^(NSError* error) {
        [_refreshControl endPullDownRefreshing];
        [SVProgressHUD showError:error];
    }];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* activities = _activities[_displayingActivityCategory];
    if (activities != nil)
    {
        return activities.count;
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OWTActivityTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"OWTActivityTableViewCell" forIndexPath:indexPath];

    NSArray* activities = _activities[_displayingActivityCategory];

    OWTMergedActivity* mergedActivity = [activities objectAtIndex:indexPath.row];
    cell.mergedActivity = mergedActivity;
    cell.userClickedAction = ^(NSString* userID) { [self presentUser:userID]; };
    cell.assetClickedAction = ^(NSString* assetID) { [self presentAsset:assetID]; };

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if ENABLE_CELLHEIGHT
    int row = (int)indexPath.row;

    if (_cachedCellHeights[_displayingActivityCategory][row] == 0)
    {
        OWTMergedActivity* mergedActivity = [_activities[_displayingActivityCategory] objectAtIndex:row];
        _dummyTableViewCell.mergedActivity = mergedActivity;

        CGSize fittingSize = [_dummyTableViewCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        _cachedCellHeights[_displayingActivityCategory][row] = fittingSize.height;
    }

    return _cachedCellHeights[_displayingActivityCategory][row];
#else
    return 0;
#endif
}

#pragma mark -q

- (void)presentUser:(NSString*)userID
{
    
    
    
//    NSLog(@"ddddddddddddddddd%@",userID);
    
    
    OWTUser* ownerUser = [GetUserManager() userForID:userID];
    if (ownerUser != nil)
    {
       
//        if ([ownerUser.userID isEqualToString:GetUserManager().currentUser.userID ]) {
//            AlbumPhotosListView * userViewCon = [[AlbumPhotosListView alloc] initWithNibName:nil bundle:nil];
//            [self.navigationController pushViewController:userViewCon animated:YES];
//           
//        }
////        userViewCon.user = ownerUser;
//        else
//        {
            OWTUserViewCon* userViewCon1 = [[OWTUserViewCon alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:userViewCon1 animated:YES];
            userViewCon1.user =ownerUser;
        
        
        
//        }
        
    }
}

- (void)presentAsset:(NSString*)assetID
{
    OWTAsset* asset = [GetAssetManager() getAssetWithID:assetID];
    if (asset != nil)
    {
        OWTAssetViewCon* assetViewCon = [[OWTAssetViewCon alloc] initWithAsset:asset];
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
    return YES;
}
- (void)beginLoadMoreRefreshing
{
    [self loadMoreFeedItems];
}


//
- (void)loadMoreFeedItems
{
    
    OWTActivityManager* am = GetActivityManager();
    
    [am loadMoreWithSuccess:^(NSArray* mergedActivities) {
        [_refreshControl endPullDownRefreshing];
        _activities[nWTActivityCategoryFollowing] = mergedActivities;
#if ENABLE_CELLHEIGHT
        _cachedCellHeights[nWTActivityCategoryFollowing].clear();
        _cachedCellHeights[nWTActivityCategoryFollowing].resize(mergedActivities.count);
#endif
        
#if ENABLE_CELLHEIGHT
        _cachedCellHeights[nWTActivityCategoryFollower].clear();
        _cachedCellHeights[nWTActivityCategoryFollower].resize(mergedActivities.count);
#endif
#if ENABLE_CELLHEIGHT
        _cachedCellHeights[nWTActivityCategoryFriends].clear();
        _cachedCellHeights[nWTActivityCategoryFriends].resize(mergedActivities.count);
#endif

        [self.tableView reloadData];
    } failure:^(NSError* error) {
        
        //结束下拉刷新
        [_refreshControl endPullDownRefreshing];
        [SVProgressHUD showError:error];
    }];

  
    
   
        

    

    
    
    
//    [am loadMoreWithSuccess:<#^(NSArray *mergedActivities)success#> failure:<#^(NSError *error)failure#>]
//    
//    [am loadMoreWithSuccess:^(NSArray* mergedActivities) failure:{ [self onLoadMoreDone]; }
//                       failure:^(NSError* error) {
//                           [self onLoadMoreDone];
//                           [SVProgressHUD showError:error];
//                       }];
}

- (void)onLoadMoreDone
{
    [self.tableView reloadData];
//    [self.tableView.infiniteScrollingView stopAnimating];
}

@end
