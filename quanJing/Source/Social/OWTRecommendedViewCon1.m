//
//  OWTRecommendedViewCon.m
//  Weitu
//
//  Created by Su on 8/17/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTRecommendedViewCon1.h"
#import "OWTRecommendedTableCell.h"

#import "SVProgressHUD+WTError.h"
#import "OWTUser.h"
#import "OWTUserManager.h"
#import "OWTAssetManager.h"
#import "OWTUserViewCon.h"
#import "OWTAssetViewCon.h"

@interface OWTRecommendedViewCon1 ()
{
    XHRefreshControl* _refreshControl;
}

@property (nonatomic, copy) NSArray* users;
@property (nonatomic, strong) NSDictionary* recommendedAssetsByUserID;

@end

@implementation OWTRecommendedViewCon1

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor colorWithWhite:0.0 alpha:0.1];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 4, 0, 4);
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 4)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 4)];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"OWTRecommendedTableCell" bundle:nil]
         forCellReuseIdentifier:@"OWTRecommendedTableCell"];

    _refreshControl = [[XHRefreshControl alloc] initWithScrollView:self.tableView delegate:self];

    self.tableView.allowsSelection = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshIfNeeded];
}

- (void)refreshIfNeeded
{
    if (_users == nil || _recommendedAssetsByUserID == nil)
    {
        [self refresh];
    }
}

- (void)manualRefresh
{
    [_refreshControl startPullDownRefreshing];
}

- (void)refresh
{
    OWTRecommendationManager1* rm = GetRecommendationManager1();

    [rm fetchRecommendedUsersWithSuccess1:^(NSArray* users, NSDictionary* recommendedAssetsByUserID) {
        [_refreshControl endPullDownRefreshing];
        _users = users;
        _recommendedAssetsByUserID = recommendedAssetsByUserID;
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
    if (_users != nil)
    {
        return _users.count;
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OWTRecommendedTableCell* cell = [tableView dequeueReusableCellWithIdentifier:@"OWTRecommendedTableCell" forIndexPath:indexPath];

    OWTUser* user = _users[indexPath.row];

    cell.user = user;
    cell.assets = _recommendedAssetsByUserID[user.userID];

    __weak OWTRecommendedViewCon1* wself = self;
    cell.presentAssetAction = ^(NSString* assetID) { [wself presentAsset:assetID]; };
    cell.presentUserAction = ^(NSString* userID) { [wself presentUser:userID]; };

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130.0;
}

#pragma mark -

- (void)presentUser:(NSString*)userID
{
    OWTUser* ownerUser = [GetUserManager() userForID:userID];
    if (ownerUser != nil)
    {
        OWTUserViewCon* userViewCon = [[OWTUserViewCon alloc] initWithNibName:nil bundle:nil];
        userViewCon.user = ownerUser;
        [self.navigationController pushViewController:userViewCon animated:YES];
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
