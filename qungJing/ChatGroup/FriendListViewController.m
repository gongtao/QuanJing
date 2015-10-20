//
//  FriendListViewController.m
//  Weitu
//
//  Created by denghs on 15/6/1.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "FriendListViewController.h"
//#import "UIViewController+HUD.h"
#import "OWTUserManager.h"
#import "HxNickNameImageModel.h"
#import "CustomBaseTableViewCell.h"
#import "OWTUserViewCon.h"
#import "OWTUser.h"
#import "MBProgressHUD.h"
#import "RRConst.h"
#import "SRRefreshView.h"


@interface FriendListViewController ()<SRRefreshDelegate>
{
    MBProgressHUD* _progress;
}
@property (strong, nonatomic) NSMutableArray *contacts;
@property (strong, nonatomic) OWTUser *user;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) UILabel *noMesglable;
@property (strong, nonatomic) SRRefreshView *slimeView;

@end

@implementation FriendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    _progress = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_progress];
    [self.view bringSubviewToFront:_progress];
    _progress.labelText = @"请稍候...";
    [_progress show:YES];
    
    self.title = @"我的好友";
    [self getFriendsList];
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.slimeView];
    [self.view bringSubviewToFront:_progress];

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


-(void)getFriendsList
{
    _user =  [[OWTUser alloc]init];
    __weak FriendListViewController* wself = self;
    
    _user.userID = GetUserManager().currentUser.userID;
    OWTUserManager* um = GetUserManager();
    
    [um getUserFriendByUser:wself.user
                    success:^{
                        _dataSource = wself.user.friendListArray ;
                        //拿着一组ID，如果本地没有 就去缓存头像
                        [HxNickNameImageModel getProfileByavatarUrl:_dataSource];
                        [self loadDataSource];
                    }
                    failure:^(NSError* error) {
                        // [SVProgressHUD showError:error];
                        //  if (loadMoreDoneFunc != nil)
                        // {
                        //   loadMoreDoneFunc();
                        // }
                    }];
    
}

-(void)loadDataSource
{
    if (_progress) {
        [_progress removeFromSuperview];
        _progress = nil;
    }
    if (_dataSource.count<1) {
        [self showUserHaveNoMessage];
        [self.view bringSubviewToFront:_noMesglable];
        [_slimeView endRefresh];
         return;
    }
    
    [_noMesglable setHidden:YES];
    [_noMesglable removeFromSuperview];
    [self.view addSubview:_tableView];
    [_tableView reloadData];
    [_slimeView endRefresh];

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



#pragma -mark 点击聊天页面的用户头像 跳转到用户信息详情页
-(void)showUserDetailPage:(NSString*)userID
{
    //从管理器中所有的ID中选中 当前被选中的用户信息（通过ownerUserID 拿到比如 UserID的传入）
    OWTUser* user = [[OWTUser alloc]init];
    user.userID = userID;
    
    OWTUserManager* um = GetUserManager();
    [um refreshPublicInfoForUser:user
                         success:^{
                             OWTUserViewCon* userViewCon1 = [[OWTUserViewCon alloc] initWithNibName:nil bundle:nil];
                             userViewCon1.hidesBottomBarWhenPushed = YES;
                             [self.navigationController pushViewController:userViewCon1 animated:YES];
                             userViewCon1.user =user;
                         }
                         failure:^(NSError* error) {
                             
                         }];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ContactListCell";
    CustomBaseTableViewCell *cell = (CustomBaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[CustomBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setCheckImageViewHidden:YES];
    OWTUser *usr = [_dataSource  objectAtIndex:indexPath.row];
    cell.imageView.image = [HxNickNameImageModel getProfileImageWithoutPrefix:usr.userID];
    cell.textLabel.text = usr.nickname ;
    
    return cell;
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OWTUser *usr = [_dataSource objectAtIndex:indexPath.row];
    [self showUserDetailPage:usr.userID];

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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
