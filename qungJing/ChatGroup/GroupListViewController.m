/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "GroupListViewController.h"

//#import "EMSearchBar.h"
#import "SRRefreshView.h"
#import "BaseTableViewCell.h"
#import "EMSearchDisplayController.h"
#import "ChatViewController_rename.h"
#import "CreateGroupViewController.h"
#import "PublicGroupListViewController.h"
//#import "RealtimeSearchUtil.h"
#import "UIViewController+HUD.h"
#import "OWTUserManager.h"

@interface GroupListViewController ()<UISearchBarDelegate, UISearchDisplayDelegate, IChatManagerDelegate, SRRefreshDelegate>

@property (strong, nonatomic) NSMutableArray *dataSource;

@property (strong, nonatomic) SRRefreshView *slimeView;
//@property (strong, nonatomic) EMSearchBar *searchBar;
@property (strong, nonatomic) EMSearchDisplayController *searchController;

@end

@implementation GroupListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _dataSource = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    self.title = NSLocalizedString(@"title.group", @"Group");
    
#warning 把self注册为SDK的delegate
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    //self.tableView.tableHeaderView = self.searchBar;
    [self.tableView addSubview:self.slimeView];
    [self searchController];
    
//    UIButton *publicButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
//    [publicButton setImage:[UIImage imageNamed:@"nav_createGroup"] forState:UIControlStateNormal];
//    [publicButton addTarget:self action:@selector(showPublicGroupList) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *publicItem = [[UIBarButtonItem alloc] initWithCustomView:publicButton];
//    
//    UIButton *createButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
//    [createButton setImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
//    [createButton addTarget:self action:@selector(createGroup) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *createGroupItem = [[UIBarButtonItem alloc] initWithCustomView:createButton];
//    
//    [self.navigationItem setRightBarButtonItems:@[createGroupItem, publicItem]];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 15, 30)];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    [self reloadDataSource];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - getter

- (SRRefreshView *)slimeView
{
    if (_slimeView == nil) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor grayColor];
        _slimeView.slime.skinColor = [UIColor grayColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor grayColor];
    }
    
    return _slimeView;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GroupCell";
    BaseTableViewCell *cell = (BaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0) {

        cell.textLabel.text = NSLocalizedString(@"group.create.group",@"Create a group");
        cell.roudContactProfile.image = [UIImage imageNamed:@"group_joinpublicgroup_"];
        
    } else {
        EMGroup *group = [self.dataSource objectAtIndex:indexPath.row];
        NSString *imageName = @"groupPublicHeader_";
//        NSString *imageName = group.isPublic ? @"groupPublicHeader" : @"groupPrivateHeader";
        cell.roudContactProfile.image = [UIImage imageNamed:imageName];
        if (group.groupSubject && group.groupSubject.length > 0) {
            cell.textLabel.text = group.groupSubject;
        }
        else {
            cell.textLabel.text = group.groupId;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
         [self createGroup];
    } else {
        EMGroup *group = [self.dataSource objectAtIndex:indexPath.row];
        ChatViewController_rename *chatController = [[ChatViewController_rename  alloc] initWithChatter:group.groupId isGroup:YES tile1:@"" title2:@""];
        chatController.title = group.groupSubject;
        chatController.currentUserImage = GetUserManager().currentUser.currentImage;

        [self.navigationController pushViewController:chatController animated:YES];
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (section == 0)
//    {
//        return 0;
//    }
//    else{
//        return 22;
//    }
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if (section == 0)
//    {
//        return nil;
//    }
//    
//    UIView *contentView = [[UIView alloc] init];
//    [contentView setBackgroundColor:[UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0]];
//    return contentView;
//}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    
    return YES;
}

#pragma mark - SRRefreshDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_slimeView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_slimeView scrollViewDidEndDraging];
}

- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsListWithCompletion:^(NSArray *groups, EMError *error) {
        if (!error) {
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:groups];
            [self.tableView reloadData];
        }
    } onQueue:nil];
    
//    [[EaseMob sharedInstance].chatManager asyncFetchAllPrivateGroupsWithCompletion:^(NSArray *groups, EMError *error) {
//        
//    } onQueue:nil];
    
    [_slimeView endRefresh];
}

#pragma mark - IChatManagerDelegate

- (void)groupDidUpdateInfo:(EMGroup *)group error:(EMError *)error
{
    if (!error) {
        [self reloadDataSource];
    }
}

- (void)didUpdateGroupList:(NSArray *)allGroups error:(EMError *)error
{
    [self reloadDataSource];
}

#pragma mark - data

- (void)reloadDataSource
{
    [self.dataSource removeAllObjects];
    
    NSArray *rooms = [[EaseMob sharedInstance].chatManager groupList];
    [self.dataSource addObjectsFromArray:rooms];
    
    [self.tableView reloadData];
}

#pragma mark - action

- (void)showPublicGroupList
{
    PublicGroupListViewController *publicController = [[PublicGroupListViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:publicController animated:YES];
}

- (void)createGroup
{
    CreateGroupViewController *createChatroom = [[CreateGroupViewController alloc] init];
    createChatroom.contactVC = _contactVC;
    [self.navigationController pushViewController:createChatroom animated:YES];
}


@end
