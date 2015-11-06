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

#import "ContactsViewController.h"

#import "BaseTableViewCell.h"
#import "ChineseToPinyin.h"
#import "SRRefreshView.h"
#import "EMSearchDisplayController.h"
#import "GroupListViewController.h"
#import "ChatViewController_rename.h"
#import "OWTUser.h"
#import "OWTUserManager.h"
#import "HxNickNameImageModel.h"
#import "OWTUserViewCon.h"
#import "UIScrollView+MJRefresh.h"
#import "UIViewController+HUD.h"
#import "MBProgressHUD.h"
#import <UIImageView+WebCache.h>


@interface ContactsViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, BaseTableCellDelegate, SRRefreshDelegate>
{
    NSIndexPath *_currentLongPressIndex;
    MBProgressHUD* _progress;
    
}

@property (strong, nonatomic) NSMutableArray *contactsSource;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) NSArray *friendsArray;
@property (strong, nonatomic) NSMutableArray *sectionTitles;

@property (strong, nonatomic) UILabel *unapplyCountLabel;
@property (strong, nonatomic) UITableView *tableView;
//@property (strong, nonatomic) EMSearchBar *searchBar;
@property (strong, nonatomic) SRRefreshView *slimeView;
@property (strong, nonatomic) GroupListViewController *groupController;

@property (strong, nonatomic) EMSearchDisplayController *searchController;

@property (strong, nonatomic)OWTUser *user;
;

@end

@implementation ContactsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataSource = [NSMutableArray array];
        _contactsSource = [NSMutableArray array];
        _sectionTitles = [NSMutableArray array];
        _friendsArray = [NSArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.tableView];
    //[self.tableView addSubview:self.slimeView];
    
    _progress = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_progress];
    [self.view bringSubviewToFront:_progress];
    _progress.labelText = @" 请稍候...";
    [_progress show:YES];
    
    //[self.slimeView setLoadingWithExpansion];
    [self setupRefresh];
    
    self.title = @"通讯录";
    [self getCacheData];
    [self getFriendsList];
    [self.view bringSubviewToFront:_progress];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

#pragma mark 刷新数据
- (void)setupRefresh
{
    //下拉刷新
    [_tableView addHeaderWithTarget:self action:@selector(getFriendsList) dateKey:@"tables"];
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


- (UILabel *)unapplyCountLabel
{
    if (_unapplyCountLabel == nil) {
        _unapplyCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(36, 5, 20, 20)];
        _unapplyCountLabel.textAlignment = NSTextAlignmentCenter;
        _unapplyCountLabel.font = [UIFont systemFontOfSize:11];
        _unapplyCountLabel.backgroundColor = [UIColor redColor];
        _unapplyCountLabel.textColor = [UIColor whiteColor];
        _unapplyCountLabel.layer.cornerRadius = _unapplyCountLabel.frame.size.height / 2;
        _unapplyCountLabel.hidden = YES;
        _unapplyCountLabel.clipsToBounds = YES;
    }
    
    return _unapplyCountLabel;
}

- (SRRefreshView *)slimeView
{
    if (_slimeView == nil) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = NO;
        _slimeView.slime.bodyColor = [UIColor grayColor];
        _slimeView.slime.skinColor = [UIColor grayColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor grayColor];
    }
    
    return _slimeView;
}

- (UITableView *)tableView
{
    if (_tableView == nil)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.sectionIndexBackgroundColor=[UIColor lightGrayColor];
    }
    
    return _tableView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.dataSource count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }
    
    return [[self.dataSource objectAtIndex:(section - 1)] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BaseTableViewCell *cell;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        static NSString *CellIdentifier = @"ContactListCell";
        cell = (BaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        // Configure the cell...
        if (cell == nil) {
            cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.delegate = self;
        }
        
        cell.indexPath = indexPath;
        if (indexPath.section == 0 && indexPath.row == 0) {
            cell.roudContactProfile.image = [UIImage imageNamed:@"groupPrivateHeader"];
            //group_joinpublicgroup_
            cell.textLabel.text = NSLocalizedString(@"title.group", @"Group");
        }
        
    }
    else{
        static NSString *CellIdentifier = @"ContactListCell";
        cell = (BaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        // Configure the cell...
        if (cell == nil) {
            cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.delegate = self;
        }
        
        cell.indexPath = indexPath;
        __weak BaseTableViewCell *wself = cell;

        QJUser *user = [[self.dataSource objectAtIndex:(indexPath.section - 1)] objectAtIndex:indexPath.row];
        
        NSString *adaptURL = [QJInterfaceManager thumbnailUrlFromImageUrl:user.avatar size:CGSizeMake(50, 50)];
        if (adaptURL == nil) {
            [cell.roudContactProfile setImage:[UIImage imageNamed:@"chatListCellHead"]];
        }else{
            [cell.roudContactProfile  setImageWithURL:[NSURL URLWithString:adaptURL]
                                     placeholderImage:nil/*[UIImage imageNamed:@"chatListCellHead"]*/
                                            completed:^(UIImage * image, NSError * error, SDImageCacheType cacheType) {
                                                if (image == nil) {
                                                    [wself.roudContactProfile setImage:[UIImage imageNamed:@"chatListCellHead"]];
                                                }
                                            }];
        }

        cell.textLabel.text = (user.nickName.length>0)? user.nickName:[user.uid stringValue];
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == 0) {
        return NO;
        [self isViewLoaded];
    }
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
        NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
        EMBuddy *buddy = [[self.dataSource objectAtIndex:(indexPath.section - 1)] objectAtIndex:indexPath.row];
        if ([buddy.username isEqualToString:loginUsername]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"friend.notDeleteSelf", @"can't delete self") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
            [alertView show];
            
            return;
        }
        
        [tableView beginUpdates];
        [[self.dataSource objectAtIndex:(indexPath.section - 1)] removeObjectAtIndex:indexPath.row];
        [self.contactsSource removeObject:buddy];
        [tableView  deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView  endUpdates];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            EMError *error;
            [[EaseMob sharedInstance].chatManager removeBuddy:buddy.username removeFromRemote:YES error:&error];
            if (!error) {
                [[EaseMob sharedInstance].chatManager removeConversationByChatter:buddy.username deleteMessages:YES append2Chat:YES];
            }
        });
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 || [[self.dataSource objectAtIndex:(section - 1)] count] == 0)
    {
        return 0;
    }
    else{
        return 22;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0 || [[self.dataSource objectAtIndex:(section - 1)] count] == 0)
    {
        return nil;
    }
    
    UIView *contentView = [[UIView alloc] init];
    [contentView setBackgroundColor:[UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 22)];
    label.backgroundColor = [UIColor clearColor];
    [label setText:[self.sectionTitles objectAtIndex:(section - 1)]];
    [contentView addSubview:label];
    return contentView;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray * existTitles = [NSMutableArray array];
    //section数组为空的title过滤掉，不显示
    for (int i = 0; i < [self.sectionTitles count]; i++) {
        if ([[self.dataSource objectAtIndex:i] count] > 0) {
            [existTitles addObject:[self.sectionTitles objectAtIndex:i]];
        }
    }
    return existTitles;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (_groupController == nil) {
            _groupController = [[GroupListViewController alloc] initWithStyle:UITableViewStylePlain];
            _groupController.contactVC = self;
        }
        else{
            [_groupController reloadDataSource];
        }
        [self.navigationController pushViewController:_groupController animated:YES];
    }
    else{
        QJUser *user = [[self.dataSource objectAtIndex:(indexPath.section - 1)] objectAtIndex:indexPath.row];
        [self showUserDetailPage:user];
        
    }
}



#pragma -mark 点击聊天页面的用户头像 跳转到用户信息详情页
-(void)showUserDetailPage:(QJUser*)user
{
    //从管理器中所有的ID中选中 当前被选中的用户信息（通过ownerUserID 拿到比如 UserID的传入）
    
    OWTUserViewCon* userViewCon1 = [[OWTUserViewCon alloc] initWithNibName:nil bundle:nil];
    userViewCon1.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:userViewCon1 animated:YES];
    userViewCon1.quser = user;
    
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex && _currentLongPressIndex) {
        EMBuddy *buddy = [[self.dataSource objectAtIndex:(_currentLongPressIndex.section - 1)] objectAtIndex:_currentLongPressIndex.row];
        [self.tableView beginUpdates];
        [[self.dataSource objectAtIndex:(_currentLongPressIndex.section - 1)] removeObjectAtIndex:_currentLongPressIndex.row];
        [self.contactsSource removeObject:buddy];
        [self.tableView  deleteRowsAtIndexPaths:[NSArray arrayWithObject:_currentLongPressIndex] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView  endUpdates];
        
        [[EaseMob sharedInstance].chatManager blockBuddy:buddy.username relationship:eRelationshipBoth];
    }
    
    _currentLongPressIndex = nil;
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
//刷新列表
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    __weak ContactsViewController *weakSelf = self;
    [[[EaseMob sharedInstance] chatManager] asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
        if (!error) {
            [weakSelf reloadDataSource];
        }
        
        [weakSelf.slimeView endRefresh];
        
    } onQueue:nil];
}



#pragma mark - BaseTableCellDelegate

- (void)cellImageViewLongPressAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1) {
        // 群组
        return;
    }
    NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
    NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
    EMBuddy *buddy = [[self.dataSource objectAtIndex:(indexPath.section - 1)] objectAtIndex:indexPath.row];
    if ([buddy.username isEqualToString:loginUsername])
    {
        return;
    }
    
    _currentLongPressIndex = indexPath;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"friend.block", @"join the blacklist") otherButtonTitles:nil, nil];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}

#pragma mark - private

- (NSMutableArray *)sortDataArray:(NSArray *)dataArray
{
    //建立索引的核心
    UILocalizedIndexedCollation *indexCollation = [UILocalizedIndexedCollation currentCollation];
    
    [self.sectionTitles removeAllObjects];
    [self.sectionTitles addObjectsFromArray:[indexCollation sectionTitles]];
    
    //返回27，是a－z和＃
    NSInteger highSection = [self.sectionTitles count];
    //tableView 会被分成27个section
    NSMutableArray *sortedArray = [NSMutableArray arrayWithCapacity:highSection];
    for (int i = 0; i <= highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sortedArray addObject:sectionArray];
    }
    
    //名字分section
    for (QJUser *user in dataArray) {
        //getUserName是实现中文拼音检索的核心，见NameIndex类
        NSString *nameStr;
        
        @try {
            nameStr = (user.nickName != nil)?user.nickName:[user.uid stringValue];
            
        }
        @catch (NSException *exception) {
            NSLog(@"yichang here %@",exception);
        }
        
        if (!nameStr.length>0) {
            continue;
        }
        NSString *firstLetter = [ChineseToPinyin pinyinFromChineseString:nameStr];
        
        NSInteger section = [indexCollation sectionForObject:[firstLetter substringToIndex:1] collationStringSelector:@selector(uppercaseString)];
        
        NSMutableArray *array = [sortedArray objectAtIndex:section];
        [array addObject:user];
    }
    
    //每个section内的数组排序
    for (int i = 0; i < [sortedArray count]; i++) {
        NSArray *array = [[sortedArray objectAtIndex:i] sortedArrayUsingComparator:^NSComparisonResult(QJUser *obj1, QJUser *obj2) {
            NSString *firstLetter1 = [ChineseToPinyin pinyinFromChineseString:(obj1.nickName != nil && obj1.nickName.length>0)?obj1.nickName:[obj1.uid stringValue]];
            firstLetter1 = [[firstLetter1 substringToIndex:1] uppercaseString];
            
            NSString *firstLetter2 = [ChineseToPinyin pinyinFromChineseString:(obj2.nickName != nil && obj2.nickName.length>0)?obj2.nickName:[obj2.uid stringValue]];
            firstLetter2 = [[firstLetter2 substringToIndex:1] uppercaseString];
            
            return [firstLetter1 caseInsensitiveCompare:firstLetter2];
        }];
        
        //根据nickName的排序，对字典重新排列
        
        [sortedArray replaceObjectAtIndex:i withObject:[NSMutableArray arrayWithArray:array]];
    }
    
    return sortedArray;
}


-(void)getCacheData
{
    NSString *homeDictionary = NSHomeDirectory();//获取根目录
    NSString *homePath  = [homeDictionary stringByAppendingString:@"/Documents/hxCache.archiver"];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:homePath];
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    if (array.count >0) {
        for (NSDictionary* dic in array) {
            NSDictionary *json = [dic objectForKey:@"uid"];
            QJUser *user = [[QJUser alloc]initWithJson:json];
            [dataArray addObject:user];
        }
        [self goAssembleData:dataArray];

    }
}

#pragma mark - dataSource

-(void)getFriendsList
{
    [_progress setHidden:NO];
    __weak ContactsViewController* wself = self;
    NSString *homeDictionary = NSHomeDirectory();//获取根目录
    NSString *homePath  = [homeDictionary stringByAppendingString:@"/Documents/hxCache.archiver"];
    
    NSArray *tmpCache = [NSKeyedUnarchiver unarchiveObjectWithFile:homePath];
    NSMutableArray *cacheArray = [[NSMutableArray alloc]initWithArray:tmpCache];
    
    //从cacheArray 取出uid存入cacheValue
    NSMutableArray *cacheValue = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in cacheArray) {
        [cacheValue addObject:[[dic objectForKey:@"uid"] objectForKey:@"uid"]];
    }
    //异步线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //耗时操作
        [[QJPassport sharedPassport]requestUserFriendList:[[QJPassport sharedPassport]currentUser].uid finished:^(NSArray * userArray, NSError * error){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error == nil) {
                    for (QJUser *user in userArray) {
                        if (user.uid != nil && user.nickName != nil &&  user.avatar != nil) {
                            if (![cacheValue containsObject:user.uid]) {
                                NSDictionary *dic = [NSDictionary dictionaryWithObjects:@[user.uid,user.nickName,user.avatar] forKeys:@[@"uid",@"nickName",@"avatar"]];
                                [cacheArray addObject:[NSDictionary dictionaryWithObject:dic forKey:@"uid"]];
                                [NSKeyedArchiver archiveRootObject:cacheArray toFile:homePath];
                            }
                        }
                    }
                    [_dataSource removeAllObjects];
                    [self goAssembleData:[NSMutableArray arrayWithArray:userArray]];
                    [wself hideHud];
                    [_tableView headerEndRefreshing];
                    [_progress setHidden:YES];
                    
                }else{
                    [_tableView headerEndRefreshing];
                    [_progress setHidden:YES];
                    [SVProgressHUD showErrorWithStatus:@"获取失败"];
                }
            });
        }];
    });

    
}

-(void)goAssembleData:(NSMutableArray *)array
{
    [self.dataSource removeAllObjects];
    [self.contactsSource  removeAllObjects];
    
    self.contactsSource = array;
    [self.dataSource addObjectsFromArray:[self sortDataArray:self.contactsSource]];
    
    [_tableView reloadData];
    
}
- (void)reloadDataSource
{
    
}

#pragma mark - action

- (void)reloadApplyView
{
    NSInteger count =0;
    
    if (count == 0) {
        self.unapplyCountLabel.hidden = YES;
    }
    else
    {
        NSString *tmpStr = [NSString stringWithFormat:@"%i", (int)count];
        CGSize size = [tmpStr sizeWithFont:self.unapplyCountLabel.font constrainedToSize:CGSizeMake(50, 20) lineBreakMode:NSLineBreakByWordWrapping];
        CGRect rect = self.unapplyCountLabel.frame;
        rect.size.width = size.width > 20 ? size.width : 20;
        self.unapplyCountLabel.text = tmpStr;
        self.unapplyCountLabel.frame = rect;
        self.unapplyCountLabel.hidden = NO;
    }
}

- (void)reloadGroupView
{
    [self reloadApplyView];
    
    if (_groupController) {
        [_groupController reloadDataSource];
    }
}

- (void)addFriendAction
{
    
}


@end
