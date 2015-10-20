//
//  FriendListViewController.m
//  Weitu
//
//  Created by denghs on 15/5/28.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "AddFriendListViewController.h"
#import "CustomBaseTableViewCell.h"
#import "OWTUserManager.h"
#import "HxNickNameImageModel.h"
#import "UIViewController+HUD.h"
#import "OWTUser.h"
#import "ChatViewController_rename.h"
#import "MBProgressHUD.h"
#import "RRConst.h"
#import "SRRefreshView.h"
#import "ContactsViewController.h"
#import "UIScrollView+MJRefresh.h"

@interface AddFriendListViewController ()<SRRefreshDelegate>
{
    MBProgressHUD* _progress;
}

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSMutableArray *selectedContacts;
@property (strong, nonatomic) NSArray *userFirendList;
@property (strong, nonatomic) OWTUser *user;
@property (strong, nonatomic) NSMutableArray *ewMenber;
@property (strong, nonatomic) NSMutableArray *contacts;
@property (strong, nonatomic) UILabel *noMesglable;
@property (strong, nonatomic) SRRefreshView *slimeView;
@end

@implementation AddFriendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _progress = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_progress];
    [self.view bringSubviewToFront:_progress];
    _progress.labelText = @"请稍候...";
    [_progress show:YES];
    
    
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [doneButton setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    
    [doneButton setTitle:@"完成" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(addgropChatAction:) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    [self.navigationItem setRightBarButtonItem:doneItem];
    
    self.title = @"发起群聊";
    _contacts = [[NSMutableArray alloc]init];
    _selectedContacts = [[NSMutableArray alloc]init];
    _dataSource = [[NSArray alloc]init];
    _ewMenber = [[NSMutableArray alloc]init];
    _userFirendList = [[NSArray alloc]init];
    [self getFriendsList];
    [self.view addSubview:self.tableView];
    [self setupRefresh];
    
    //[self.tableView addSubview:self.slimeView];
    [self.view bringSubviewToFront:_progress];
    
    
}

#pragma mark 刷新数据
- (void)setupRefresh
{
    //下拉刷新
    [_tableView addHeaderWithTarget:self action:@selector(getFriendsList) dateKey:@"list"];
    //[_tableView headerBeginRefreshing];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    // [_tableView addFooterWithTarget:self action:@selector(loadMoreFeedItems)];
    //一些设置
    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
    _tableView.headerPullToRefreshText = @"";
    _tableView.headerReleaseToRefreshText = @"";
    _tableView.headerRefreshingText = @"";
    
    _tableView.footerPullToRefreshText = @"";
    _tableView.footerReleaseToRefreshText = @"";
    _tableView.footerRefreshingText = @"";
}

-(void)addgropChatAction:(UIButton*)sender
{
    if (_existMenberArray) {
        for (OWTUser *user in _selectedContacts) {
            if (![_existMenberArray containsObject:user.userID]) {
                NSString *hxUserID = [@"qj" stringByAppendingString: user.userID];
                [_ewMenber addObject:hxUserID];
            }
        }
        _addFriendToGrop(_ewMenber);
    }
    else{
        if (_selectedContacts.count<1) {
            return;
        }
        [self showHudInView:self.view hint:NSLocalizedString(@"group.create.ongoing", @"create a group...")];
        NSMutableArray *source = [NSMutableArray array];
        for (OWTUser *user in _selectedContacts) {
            [source addObject: [@"qj" stringByAppendingString: user.userID]];
        }
        EMGroupStyleSetting *setting = [[EMGroupStyleSetting alloc] init];
        
        __weak AddFriendListViewController *weakSelf = self;
        NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
        NSString *username = [loginInfo objectForKey:kSDKUsername];
        NSString *messageStr = [NSString stringWithFormat:NSLocalizedString(@"group.somebodyInvite", @"%@ invite you to join groups \'%@\'"), username, @"欢迎进去群聊"];
        NSString *groupNmae = _gropName;
        if (_gropName.length == 0 || _gropName == nil) {
            groupNmae = @"群聊";
        }
        [[EaseMob sharedInstance].chatManager asyncCreateGroupWithSubject:groupNmae description:@"normal" invitees:source initialWelcomeMessage:messageStr styleSetting:setting completion:^(EMGroup *group, EMError *error) {
            [weakSelf hideHud];
            if (group && !error) {
                [weakSelf showHint:NSLocalizedString(@"group.create.success", @"create group success")];
                if (_contactVC) {
                    if ([_contactVC isKindOfClass:[ContactsViewController class]]) {
                        ContactsViewController* contactVC = (ContactsViewController*)_contactVC;
                        contactVC.creatGroupPopBack(group);
                    }
                }else{
                    _creatGroupPopBack(group);
                    
                }
            }
            else{
                [weakSelf showHint:NSLocalizedString(@"group.create.fail", @"Failed to create a group, please operate again")];
            }
        } onQueue:nil];
        
    }
}


#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_slimeView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_slimeView scrollViewDidEndDraging];
}

#pragma mark - slimeRefresh delegate
//刷新消息列表
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self getFriendsList];
}


#pragma mark - getter

- (SRRefreshView *)slimeView
{
    if (!_slimeView) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor grayColor];
        _slimeView.slime.skinColor = [UIColor grayColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor grayColor];
        _slimeView.backgroundColor = [UIColor whiteColor];
    }
    
    return _slimeView;
}


- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.editing = false;
    }
    
    return _tableView;
}
#pragma mark - action

- (void)chooseAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    if (button.selected) {
        [self.tableView setEditing:YES animated:YES];
    }
    else{
        [self.tableView setEditing:NO animated:YES];
        [self doneAction:nil];
    }
}

- (void)doneAction:(id)sender
{
    
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ContactListCell";
    CustomBaseTableViewCell *cell = (CustomBaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[CustomBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    OWTUser *usr = [_dataSource  objectAtIndex:indexPath.row];
    
    UIImage *image = [HxNickNameImageModel getProfileImageWithoutPrefix:usr.userID];
    if (image == nil) {
        cell.roudContactProfile.image = [UIImage imageNamed:@"chatListCellHead"];
    }else{
        cell.roudContactProfile.image = image;
        
    }
    cell.textLabel.text = usr.nickname ;
    
    NSUInteger row = [indexPath row];
    NSMutableDictionary *dic = [_contacts objectAtIndex:row];
    if ([[dic objectForKey:@"checked"] isEqualToString:@"NO"]) {
        [dic setObject:@"NO" forKey:@"checked"];
        [cell setChecked:NO];
        
    }else {
        [dic setObject:@"YES" forKey:@"checked"];
        [cell setChecked:YES];
    }
    
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    id object = [_dataSource objectAtIndex:indexPath.row];
    if (![self.selectedContacts containsObject:object])
    {
        [self.selectedContacts addObject:object];
        
    }
    else
    {
        [self.selectedContacts removeObject:object];
        
    }
    CustomBaseTableViewCell *cell = (CustomBaseTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    NSUInteger row = [indexPath row];
    NSLog(@"NSUInteger row = [indexPath row]=  %ld",(unsigned long)row);
    NSMutableDictionary *dic = [_contacts objectAtIndex:row];
    //选择， 由为选中改成选中
    if ([[dic objectForKey:@"checked"] isEqualToString:@"NO"]) {
        [dic setObject:@"YES" forKey:@"checked"];
        [cell setChecked:YES];
    }else {
        [dic setObject:@"NO" forKey:@"checked"];
        [cell setChecked:NO];
    }
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataSource  count];
}

-(void)loadDataSource
{
    if (_progress) {
        [_progress setHidden:NO];
        // _progress = nil;
    }
    if (_dataSource.count<1) {
        [self showUserHaveNoMessage];
        [self.view bringSubviewToFront:_noMesglable];
        [_slimeView endRefresh];
        [_progress setHidden:YES];
        
        [_tableView headerEndRefreshing];
        
        return;
    }
    
    [_noMesglable setHidden:YES];
    [_noMesglable removeFromSuperview];
    
    for (int i=0; i<_dataSource.count; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:@"NO" forKey:@"checked"];
        [_contacts addObject:dic];
    }
    [self.view addSubview:_tableView];
    [_tableView reloadData];
    [_slimeView endRefresh];
    [_tableView headerEndRefreshing];
    
    
}

-(void)showUserHaveNoMessage
{
    _noMesglable = [[UILabel alloc]init];
    _noMesglable.frame = CGRectMake(0, self.view.frame.size.height/2-50-44-22, self.view.frame.size.width, 50);
    _noMesglable.text = @"暂无好友，关注他人即可成为好友，快去关注吧";
    _noMesglable.textAlignment = NSTextAlignmentCenter;
    [_noMesglable setTextColor:HWColor(98,98,90)];
    _noMesglable.font = [UIFont fontWithName:@"Arial" size:13];
    [self.view addSubview:_noMesglable];
    
}

-(void)getFriendsList
{
    _user =  [[OWTUser alloc]init];
    __weak AddFriendListViewController* wself = self;
    [_progress setHidden:NO];
    
    _user.userID = GetUserManager().currentUser.userID;
    OWTUserManager* um = GetUserManager();
    
    [um getUserFriendByUser:wself.user
                    success:^{
                        _userFirendList = wself.user.friendListArray ;
                        _dataSource = _userFirendList;
                        //拿着一组ID，如果本地没有 就去缓存头像
                        [HxNickNameImageModel getProfileByavatarUrl:_dataSource];
                        [self loadDataSource];
                        [_tableView headerEndRefreshing];
                        [_progress setHidden:YES];
                    }
                    failure:^(NSError* error) {
                        [_tableView headerEndRefreshing];
                        [_progress setHidden:YES];
                        // [SVProgressHUD showError:error];
                        //  if (loadMoreDoneFunc != nil)
                        // {
                        //   loadMoreDoneFunc();
                        // }
                    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
