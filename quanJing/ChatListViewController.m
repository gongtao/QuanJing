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

#import "ChatListViewController.h"
#import "ChatListCell.h"
#import "NSDate+Category.h"
#import "ChatViewController_rename.h"
#import "EMSearchDisplayController.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "IChatManagerDelegate.h"
#import "EaseMob.h"
#import "EMMessage.h"
#import "EMConversation.h"
#import "HxNickNameImageModel.h"
#import "OWTUserManager.h"
#import "RRConst.h"
#import "UIBarButtonItem+SHBarButtonItemBlocks.h"
#import "FentchListViewController.h"
#import "CreateGroupViewController.h"
#import "AddFriendListViewController.h"
#import "PoperView.h"
#import "FriendListViewController.h"
#import "OWTAuthManager.h"
#import "OWTUserInfoEditViewCon.h"
#import "ContactsViewController.h"
#import "UIScrollView+MJRefresh.h"
#import "UIViewController+WTExt.h"
#import "OWTTabBarHider.h"
#import "QJUser.h"
#import "QJPassport.h"
#import "QJInterfaceManager.h"
#import <UIImageView+WebCache.h>

@interface ChatListViewController ()<UITableViewDelegate,UITableViewDataSource, UISearchDisplayDelegate,SRRefreshDelegate, IChatManagerDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray        *dataSource;

@property (strong, nonatomic) UITableView           *tableView;
//@property (nonatomic, strong) EMSearchBar           *searchBar;
@property (nonatomic, strong) SRRefreshView         *slimeView;
@property (nonatomic, strong) UIView                *networkStateView;

@property (strong, nonatomic) EMSearchDisplayController *searchController;
@property (strong,nonatomic)UILabel *noMesglable;
@property (strong, nonatomic)PoperView *mPopView;
@property (assign, nonatomic)BOOL isSelect;
@property (strong, nonatomic)UITapGestureRecognizer *tap;
@property (strong, nonatomic)NSArray *cacheArray;
@property (strong, nonatomic)NSMutableArray *thatUsrs1;
@property (strong, nonatomic)NSMutableArray *thatUsrs2;



@end

@implementation ChatListViewController
{
    QJUser *_user;
    OWTTabBarHider * _tabBarHider;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataSource = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self substituteNavigationBarBackItem2];
    
    [self removeEmptyConversationsFromDB];
    [self setup];
    [self.view addSubview:self.tableView];
    //[self.tableView addSubview:self.slimeView];
    [self networkStateView];
    [self searchController];
    [self.view setBackgroundColor:[UIColor redColor]];
    
    [self setupFentchAddListBtn];
    [self setupPopView];
    [self setupRefresh];
    
}

-(void)setup
{
    NSString *homeDictionary = NSHomeDirectory();//获取根目录
    NSString *homePath  = [homeDictionary stringByAppendingString:@"/Documents/hxCache.archiver"];
    _cacheArray = [NSKeyedUnarchiver unarchiveObjectWithFile:homePath];
    _thatUsrs1 = [[NSMutableArray alloc]init];
    _thatUsrs2 = [[NSMutableArray alloc]init];

    if (_cacheArray.count >0) {
        for (NSDictionary* dic in _cacheArray) {
            NSDictionary *json = [dic objectForKey:@"uid"];
            QJUser *user = [[QJUser alloc]initWithJson:json];
            [_thatUsrs1 addObject:user];
        }
        
    }


}
- (void)popViewControllerWithAnimation
{
    
    _tabBarHider = [[OWTTabBarHider alloc] init];
    [_tabBarHider showTabBar];
    [self dismissViewControllerAnimated:YES
                             completion:NULL];
}

-(void)setupPopView
{
    _mPopView = [[PoperView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-5-120, -90, 120, 90)];
    [_mPopView setImage:[UIImage imageNamed:@"popBackg"]];
    [self.view addSubview:_mPopView];
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToHidePopView)];
    [self.view addGestureRecognizer:_tap];
    __typeof (self) __weak weakSelf = self;
    _mPopView.showFriendList = ^(){
        ContactsViewController *contactVC  = [[ContactsViewController alloc] initWithNibName:nil bundle:nil];
        contactVC.hidesBottomBarWhenPushed = YES;
        
        contactVC.creatGroupPopBack = ^(EMGroup* group){
            [weakSelf saveConversation];
            ChatViewController_rename *chatController = [[ChatViewController_rename alloc] initWithChatter:group.groupId isGroup:YES tile1:@"creatGropEnter" title2:@""];
            chatController.title = group.groupSubject;
            chatController.currentUserImage = GetUserManager().currentUser.currentImage;
            chatController.ifpopToRootView = YES;
            chatController.currentUserName = GetUserManager().currentUser.nickname;
            chatController.hidesBottomBarWhenPushed = YES;
            [weakSelf.navigationController pushViewController:chatController animated:YES];
        };
        
        
        [weakSelf.navigationController pushViewController:contactVC animated:YES];
    };
    
    _mPopView.addgroudTalk = ^(){
        
        weakSelf.title = @"";
        AddFriendListViewController *selectionController = [[AddFriendListViewController alloc] init];
        selectionController.hidesBottomBarWhenPushed = YES;
        
        selectionController.creatGroupPopBack = ^(EMGroup* group){
            [weakSelf saveConversation];
            ChatViewController_rename *chatController = [[ChatViewController_rename alloc] initWithChatter:group.groupId isGroup:YES tile1:@"creatGropEnter" title2:@""];
            chatController.title = group.groupSubject;
            chatController.currentUserImage = GetUserManager().currentUser.currentImage;
            chatController.currentUserName = GetUserManager().currentUser.nickname;
            chatController.hidesBottomBarWhenPushed = YES;
            [weakSelf.navigationController pushViewController:chatController animated:YES];
        };
        
        [weakSelf.navigationController pushViewController:selectionController animated:YES];
        
    };
}

#pragma mark - GestureRecognizer

// 点击背景隐藏
-(void)tapToHidePopView
{
    _isSelect = false;
    _tap.enabled = false;
    
    [UIView animateWithDuration:0.5f animations:^{
        _mPopView.transform=CGAffineTransformTranslate(_mPopView.transform, 0, -90);
        
    } completion:^(BOOL finished) {
    }];
}


-(void)setupFentchAddListBtn
{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem SH_barButtonItemWithBarButtonSystemItem:UIBarButtonSystemItemAdd withBlock:^(UIBarButtonItem* sender) {
        _isSelect = !_isSelect;
        [self tapAddButonAction:_isSelect];
    }];
}


-(void)tapAddButonAction:(BOOL)isSelect
{
    if (isSelect) {
        _mPopView.frame = CGRectMake(self.view.frame.size.width-5-120, -90, 120, 90);
        [UIView animateWithDuration:0.5f animations:^{
            _tap.enabled = true;
            _mPopView.transform=CGAffineTransformTranslate(_mPopView.transform, 0, 90);
            
        } completion:^(BOOL finished) {
        }];    }
    else
    {
        [UIView animateWithDuration:0.5f animations:^{
            _mPopView.transform=CGAffineTransformTranslate(_mPopView.transform, 0, -90);
            
        } completion:^(BOOL finished) {
        }];
        
    }
}

-(void)saveConversation
{
    /*- (BOOL)insertConversationToDB:(EMConversation *)conversation
     append2Chat:(BOOL)append2Chat;*/
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _user = [[QJPassport sharedPassport]currentUser];
    if (_user.nickName.length==0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"请先完善个人信息" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
    
        self.title = @"消息";
    [self refreshDataSource];
    [self registerNotifications];
    _mPopView.frame = CGRectMake(self.view.frame.size.width-5-120, -90, 120, 90);
    _isSelect = false;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        OWTUserInfoEditViewCon* userInfoEditViewCon = [[OWTUserInfoEditViewCon alloc] initWithNibName:nil bundle:nil];
        userInfoEditViewCon.user = _user;
        
        userInfoEditViewCon.cancelAction = ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        
        userInfoEditViewCon.doneFunc = ^{
            [self dismissViewControllerAnimated:YES completion:^{
                [_tableView reloadData];
            }];
        };
        
        UINavigationController* navCon = [[UINavigationController alloc] initWithRootViewController:userInfoEditViewCon];
        [self presentViewController:navCon animated:YES completion:nil];
    }
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterNotifications];
}

- (void)removeEmptyConversationsFromDB
{
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSMutableArray *needRemoveConversations;
    for (EMConversation *conversation in conversations) {
        if (!conversation.latestMessage) {
            if (!needRemoveConversations) {
                needRemoveConversations = [[NSMutableArray alloc] initWithCapacity:0];
            }
            
            [needRemoveConversations addObject:conversation.chatter];
        }
    }
    
    if (needRemoveConversations && needRemoveConversations.count > 0) {
        [[EaseMob sharedInstance].chatManager removeConversationsByChatters:needRemoveConversations
                                                             deleteMessages:YES
                                                                append2Chat:NO];
    }
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
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[ChatListCell class] forCellReuseIdentifier:@"chatListCell"];
    }
    
    return _tableView;
}

- (EMSearchDisplayController *)searchController
{
    
    return nil;
}

- (UIView *)networkStateView
{
    if (_networkStateView == nil) {
        _networkStateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
        _networkStateView.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:199 / 255.0 blue:199 / 255.0 alpha:0.5];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (_networkStateView.frame.size.height - 20) / 2, 20, 20)];
        imageView.image = [UIImage imageNamed:@"messageSendFail"];
        [_networkStateView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 0, _networkStateView.frame.size.width - (CGRectGetMaxX(imageView.frame) + 15), _networkStateView.frame.size.height)];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"network.disconnection", @"Network disconnection");
        [_networkStateView addSubview:label];
    }
    
    return _networkStateView;
}

#pragma mark - private  dataSource-每个联系人的数据来源
- (NSMutableArray *)loadDataSource
{
    NSMutableArray *ret = nil;
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    
    NSArray* sorte = [conversations sortedArrayUsingComparator:
                      ^(EMConversation *obj1, EMConversation* obj2){
                          EMMessage *message1 = [obj1 latestMessage];
                          EMMessage *message2 = [obj2 latestMessage];
                          if(message1.timestamp > message2.timestamp) {
                              return(NSComparisonResult)NSOrderedAscending;
                          }else {
                              return(NSComparisonResult)NSOrderedDescending;
                          }
                      }];
    
    ret = [[NSMutableArray alloc] initWithArray:sorte];
    [self getUserDisplayData:conversations];
    return ret;
}

//发起网络请求，拿到当前会话列表的所有头像和昵称，要维护一个本地队列
-(void)getUserDisplayData:(NSArray*)displayArray
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (EMConversation *conversation in displayArray) {
        NSString *str = [NSString stringWithString:conversation.chatter];
        NSString  *usrId = [str substringFromIndex:2];
        [array addObject:usrId];
    }
    
    [self getServerUsrInfo: array];
}


-(void)getServerUsrInfo:(NSArray*)usrIds
{
//    //头像等数据 若本地不存在则去请求网络
//    NSMutableArray *cacheValue = [[NSMutableArray alloc]init];
//    NSMutableArray *filetArray = [[NSMutableArray alloc]init];
//    for (NSDictionary *dic in _cacheArray) {
//        [cacheValue addObject:[[[dic objectForKey:@"uid"] objectForKey:@"uid"] stringValue]];
//    }
//    
//    for (NSString* userID in usrIds) {
//        if (![cacheValue containsObject:userID]) {
//            [filetArray addObject:userID];
//        }
//    }
    //_thatUsrs2 = [[NSMutableArray alloc]initWithArray:_thatUsrs1];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //耗时操作
        NSArray *result = [HxNickNameImageModel getTriggleValeByIDArray:usrIds];
            if (result.count >0) {
                [_thatUsrs2 removeAllObjects];
                [_thatUsrs2 addObjectsFromArray:result];
            }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
        
    });
    
}

// 得到最后消息时间
-(NSString *)lastMessageTimeByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];
    if (lastMessage) {
        ret = [NSDate formattedTimeFromTimeInterval:lastMessage.timestamp];
    }
    
    return ret;
}

// 得到未读消息条数
- (NSInteger)unreadMessageCountByConversation:(EMConversation *)conversation
{
    NSInteger ret = 0;
    ret = conversation.unreadMessagesCount;
    
    return  ret;
}

// 得到最后消息文字或者类型
-(NSString *)subTitleMessageByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];
    if (lastMessage) {
        id<IEMMessageBody> messageBody = lastMessage.messageBodies.lastObject;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Image:{
                ret = NSLocalizedString(@"message.image1", @"[image]");
            } break;
            case eMessageBodyType_Text:{
                // 表情映射。
                NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                ret = didReceiveText;
            } break;
            case eMessageBodyType_Voice:{
                ret = NSLocalizedString(@"message.voice1", @"[voice]");
            } break;
            case eMessageBodyType_Location: {
                ret = NSLocalizedString(@"message.location1", @"[location]");
            } break;
            case eMessageBodyType_Video: {
                ret = NSLocalizedString(@"message.vidio1", @"[vidio]");
            } break;
            default: {
            } break;
        }
    }
    
    return ret;
}

#pragma mark - TableViewDelegate & TableViewDatasource

-(UITableViewCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"chatListCell";
    ChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (!cell) {
        cell = [[ChatListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
    }
    
    EMConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
    //当前cell的userID,可以通过全景的API去获取头像和昵称信息
    //cell.name =  conversation.chatter;
    
    //nickName
    NSString *chater = [NSString stringWithString:conversation.chatter];
    chater = [chater substringFromIndex:2];
    QJUser *qjuser = nil;
    for (QJUser *user in _thatUsrs2) {
        if ([[user.uid stringValue] isEqualToString:chater]) {
            qjuser = user;
            break;
        }
    }
    
    //聊天者的名字
    cell.name = (qjuser.nickName.length>0)?qjuser.nickName:[qjuser.uid stringValue];
    //头像
    if (!conversation.isGroup) {
        NSString *adaptURL = [QJInterfaceManager thumbnailUrlFromImageUrl:qjuser.avatar size:CGSizeMake(50, 50)];
        cell.placeholderImage = [UIImage imageNamed:@"chatListCellHead"];
        cell.imageURL = [NSURL URLWithString:adaptURL];
    }
    //群聊
    else{
        NSString *imageName = @"groupPublicHeader";
        NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
        for (EMGroup *group in groupArray) {
            if ([group.groupId isEqualToString:conversation.chatter]) {
                cell.name = group.groupSubject;
                imageName = group.isPublic ? @"groupPublicHeader" : @"groupPrivateHeader";
                break;
            }
        }
        cell.placeholderImage = [UIImage imageNamed:imageName];
    }
    cell.detailMsg = [self subTitleMessageByConversation:conversation];
    cell.time = [self lastMessageTimeByConversation:conversation];
    cell.unreadCount = [self unreadMessageCountByConversation:conversation];
    if (indexPath.row % 2 == 1) {
        cell.contentView.backgroundColor = RGBACOLOR(246, 246, 246, 1);
    }else{
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.dataSource.count<1)
    {
        [self showUserHaveNoMessage];
        [self.view bringSubviewToFront:_noMesglable];
        
    }
    else
    {
        [_noMesglable setHidden:YES];
        [_noMesglable removeFromSuperview];
    }
    return  self.dataSource.count;
}

-(void)showUserHaveNoMessage
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _noMesglable = [[UILabel alloc]init];
        _noMesglable.frame = CGRectMake(0, self.view.frame.size.height/2-50-44-22, self.view.frame.size.width, 50);
        _noMesglable.text = @"暂时没有消息";
        _noMesglable.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_noMesglable];
    });
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ChatListCell tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EMConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
    
    ChatViewController_rename *chatController;
    NSString *title = conversation.chatter;
    if (conversation.isGroup) {
        NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
        for (EMGroup *group in groupArray) {
            if ([group.groupId isEqualToString:conversation.chatter]) {
                title = group.groupSubject;
                break;
            }
        }
    }
    
    NSString *chatter = [NSString stringWithString:conversation.chatter];

    chatController = [[ChatViewController_rename alloc] initWithChatter:chatter isGroup:conversation.isGroup tile1:@"" title2:@""];
    QJUser *qjuser = [[QJUser alloc]init];
    qjuser.uid = [NSNumber numberWithInteger:[chatter integerValue]] ;
    for (QJUser *user in _thatUsrs2) {
        if (user.uid != nil && [[user.uid stringValue] isEqualToString:[chatter substringFromIndex:2]]) {
            qjuser = user;
            break;
        }
    }
    chatController.title = (qjuser.nickName.length>0)?qjuser.nickName:[qjuser.uid stringValue];
    if (conversation.isGroup) {
        chatController.title = title;
    }
    chatController.otherUser = qjuser;
    chatController.hxUserID = conversation.chatter;
    chatController.currentUser = [[QJPassport sharedPassport]currentUser];
    chatController.hidesBottomBarWhenPushed =YES;
    [self.navigationController pushViewController:chatController animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EMConversation *converation = [self.dataSource objectAtIndex:indexPath.row];
        [[EaseMob sharedInstance].chatManager removeConversationByChatter:converation.chatter deleteMessages:YES append2Chat:YES];
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}

//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.dataSource searchText:(NSString *)searchText collationStringSelector:@selector(chatter) resultBlock:^(NSArray *results) {
//        if (results) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.searchController.resultsSource removeAllObjects];
//                [self.searchController.resultsSource addObjectsFromArray:results];
//                [self.searchController.searchResultsTableView reloadData];
//            });
//        }
//    }];
//}
//
//- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
//{
//    return YES;
//}
//
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
//{
//    [searchBar resignFirstResponder];
//}

//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
//{
//    searchBar.text = @"";
//    [[RealtimeSearchUtil currentUtil] realtimeSearchStop];
//    [searchBar resignFirstResponder];
//    [searchBar setShowsCancelButton:NO animated:YES];
//}

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
    [self refreshDataSource];
    [_slimeView endRefresh];
}

#pragma mark 刷新数据
- (void)setupRefresh
{
    //下拉刷新
    
    [_tableView addHeaderWithTarget:self action:@selector(prefreshDataSource)];
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

#pragma mark - IChatMangerDelegate

-(void)didUnreadMessagesCountChanged
{
    [self refreshDataSource];
}

- (void)didUpdateGroupList:(NSArray *)allGroups error:(EMError *)error
{
    [self refreshDataSource];
}

#pragma mark - registerNotifications
-(void)registerNotifications{
    [self unregisterNotifications];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)dealloc{
    [self unregisterNotifications];
}

#pragma mark - public

-(void)refreshDataSource
{
    
    self.dataSource = [self loadDataSource];
    [_tableView reloadData];
    //[self hideHud];
    [_tableView headerEndRefreshing];
    
}

-(void)prefreshDataSource
{
    [self refreshDataSource];
}
- (void)isConnect:(BOOL)isConnect{
    if (!isConnect) {
        _tableView.tableHeaderView = _networkStateView;
    }
    else{
        _tableView.tableHeaderView = nil;
    }
    
}

- (void)networkChanged:(EMConnectionState)connectionState
{
    if (connectionState == eEMConnectionDisconnected) {
        _tableView.tableHeaderView = _networkStateView;
    }
    else{
        _tableView.tableHeaderView = nil;
    }
}

- (void)willReceiveOfflineMessages{
    NSLog(NSLocalizedString(@"message.beginReceiveOffine", @"Begin to receive offline messages"));
}

- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages
{
    [self refreshDataSource];
}

- (void)didFinishedReceiveOfflineMessages:(NSArray *)offlineMessages{
    NSLog(NSLocalizedString(@"message.endReceiveOffine", @"End to receive offline messages"));
    [self refreshDataSource];
}



@end
