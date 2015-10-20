//
//  FentchListViewController.m
//  Weitu
//
//  Created by denghs on 15/5/27.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "FentchListViewController.h"
#import "SRRefreshView.h"
#import "ChatListCell.h"
//#import "EMSearchBar.h"
#import "NSDate+Category.h"
//导航栏 里面的边输入边搜索 的功能 全景当前不上
//#import "RealtimeSearchUtil.h"
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



@interface FentchListViewController ()<UITableViewDelegate,UITableViewDataSource, UISearchDisplayDelegate,SRRefreshDelegate, IChatManagerDelegate>

@property (strong, nonatomic) NSMutableArray        *dataSource;

@property (strong, nonatomic) UITableView           *tableView;
//@property (nonatomic, strong) EMSearchBar           *searchBar;
@property (nonatomic, strong) SRRefreshView         *slimeView;
@property (nonatomic, strong) UIView                *networkStateView;

@property (strong, nonatomic) EMSearchDisplayController *searchController;
@property (strong,nonatomic)UILabel *noMesglable;
@end

@implementation FentchListViewController

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
    [self removeEmptyConversationsFromDB];
    
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.slimeView];
    [self networkStateView];
    [self searchController];
   // [self.view setBackgroundColor:[UIColor redColor]];
    
    //    UIButton *addFentchList  = [[UIButton alloc]init];
    //    addFentchList.frame= CGRectMake(Xwidth-60, 0, 30, 30);
    //    self.navigationItem.leftBarButtonItem = [UIBarButtonItem alloc]initWithCustomView:[UIButton]
    
    //[self setupFentchAddListBtn];
}

-(void)setupFentchAddListBtn
{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem SH_barButtonItemWithBarButtonSystemItem:UIBarButtonSystemItemAdd withBlock:^(UIBarButtonItem* sender) {
        self.title = @"";
        FentchListViewController *fentchVC = [[FentchListViewController alloc]init];
        [self.navigationController pushViewController:fentchVC animated:YES];
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"消息";
    [self refreshDataSource];
    [self registerNotifications];
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

//- (UISearchBar *)searchBar
//{
//    if (!_searchBar) {
//        _searchBar = [[EMSearchBar alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 44)];
//        _searchBar.delegate = self;
//        _searchBar.placeholder = NSLocalizedString(@"search", @"Search");
//        _searchBar.backgroundColor = [UIColor colorWithRed:0.747 green:0.756 blue:0.751 alpha:1.000];
//    }
//
//    return _searchBar;
//}

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
    //    if (_searchController == nil) {
    //        _searchController = [[EMSearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    //        _searchController.delegate = self;
    //        _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //
    //        __weak ChatListViewController *weakSelf = self;
    //        [_searchController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
    //            static NSString *CellIdentifier = @"ChatListCell";
    //            ChatListCell *cell = (ChatListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //
    //            // Configure the cell...
    //            if (cell == nil) {
    //                cell = [[ChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    //            }
    //
    //            EMConversation *conversation = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
    //            cell.name = conversation.chatter;
    //            if (!conversation.isGroup) {
    //                cell.placeholderImage = [UIImage imageNamed:@"chatListCellHead.png"];
    //            }
    //            else{
    //                NSString *imageName = @"groupPublicHeader";
    //                NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
    //                for (EMGroup *group in groupArray) {
    //                    if ([group.groupId isEqualToString:conversation.chatter]) {
    //                        cell.name = group.groupSubject;
    //                        imageName = group.isPublic ? @"groupPublicHeader" : @"groupPrivateHeader";
    //                        break;
    //                    }
    //                }
    //                cell.placeholderImage = [UIImage imageNamed:imageName];
    //            }
    //            cell.detailMsg = [weakSelf subTitleMessageByConversation:conversation];
    //            cell.time = [weakSelf lastMessageTimeByConversation:conversation];
    //            cell.unreadCount = [weakSelf unreadMessageCountByConversation:conversation];
    //            if (indexPath.row % 2 == 1) {
    //                cell.contentView.backgroundColor = RGBACOLOR(246, 246, 246, 1);
    //            }else{
    //                cell.contentView.backgroundColor = [UIColor whiteColor];
    //            }
    //            return cell;
    //        }];
    //
    //        [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
    //            return [ChatListCell tableView:tableView heightForRowAtIndexPath:indexPath];
    //        }];
    //
    //        [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
    //            [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //            [weakSelf.searchController.searchBar endEditing:YES];
    //
    //            EMConversation *conversation = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
    //
    //            ChatViewController_rename *chatVC = [[ChatViewController_rename alloc] initWithChatter:conversation.chatter isGroup:conversation.isGroup tile1:@"" title2:@""];
    //
    //
    //            chatVC.title = conversation.chatter;
    //            [weakSelf.navigationController pushViewController:chatVC animated:YES];
    //        }];
    //    }
    //
    //    return _searchController;
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

//发起一个同步的网络请求(不要使用异步请求)，拿到当前会话列表的所有头像和昵称，要维护一个本地队列
-(void)getUserDisplayData:(NSArray*)displayArray
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (EMConversation *conversation in displayArray) {
        NSString  *usrId = [conversation.chatter substringFromIndex:2];
        [array addObject:usrId];
    }
    
    [self getServerUsrInfo: array];
}

-(void)getServerUsrInfo:(NSArray*)usrId
{
#pragma TODO 后期抽出时间 把这些BaseURL 定义在一个MODel里面
    NSString *urlBasePath = @"http://api.tiankong.com/qjapi/users/";
    //如果本地沙河不存在
    NSDictionary *tmpDic = [[NSUserDefaults standardUserDefaults]objectForKey:@"HxChatData"];
    if ([tmpDic isKindOfClass:[NSNull class]]) {
        tmpDic = [[NSMutableDictionary alloc]init];
    }
    NSMutableDictionary *rootDic = [[NSMutableDictionary alloc]initWithDictionary:tmpDic];
    
    NSArray *allKeys = [rootDic allKeys];
    //拿subPath作为主键去遍历保存 环信数据的沙盒
    for (NSString *subPath  in usrId)
    {
        BOOL ifAskServerAPI  = [allKeys containsObject:subPath];
        //去遍历根字典 当前的UserID不存在时 去网络请求数据
        if (!ifAskServerAPI)
        {
            urlBasePath = [urlBasePath stringByAppendingFormat:@"%@",subPath];
            NSURL *url = [NSURL URLWithString:urlBasePath];
            NSURLRequest *request =[NSURLRequest requestWithURL:url];
            NSMutableDictionary *mDic = [[NSMutableDictionary alloc]init];
            
            //同步网络请求
            NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            
            //NSJSONSerialization解析
            if (response!=nil)
            {
                NSDictionary  *dic0 =[NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:nil];
                NSLog(@"解析出来的JSON数据  %@",dic0);
                NSDictionary *appList=dic0[@"user"];
                
                //获取昵称数据
                if ([appList[@"nickname"] isKindOfClass:[NSNull class]])
                {
                    [mDic setValue:@"nil" forKey:@"nickName"];
                }else
                {
                    [mDic setValue:appList[@"nickname"] forKey:@"nickName"];
                }
                
                
                //获取头像数据
                if ([appList[@"avatarImageInfo"][@"smallURL"] isKindOfClass:[NSNull class]])
                {
                    //do something
                    [mDic setValue:@"nil" forKey:@"smallURLImage"];
                }else
                {
                    NSData *smallURLImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:appList[@"avatarImageInfo"][@"smallURL"]]];
                    [mDic setValue:smallURLImage forKey:@"smallURLImage"];
                }
                
            }
            
            //把每个元素写入根字典
            [rootDic setValue:mDic forKey:subPath];
            //数据持久化
            [[NSUserDefaults standardUserDefaults]setValue:rootDic forKey:@"HxChatData"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
    }
    
}

// 得到最后消息时间
-(NSString *)lastMessageTimeByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];;
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
    NSString *chater = [HxNickNameImageModel getNickName:conversation.chatter];
    cell.name = [HxNickNameImageModel getNickName:conversation.chatter];
    
    //头像
    if (!conversation.isGroup) {
        cell.placeholderImage = [HxNickNameImageModel getProfileImage:conversation.chatter];
        
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
    
    NSString *chatter = conversation.chatter;
    chatController = [[ChatViewController_rename alloc] initWithChatter:chatter isGroup:conversation.isGroup tile1:@"" title2:@""];
    //chatController.title = title;
    chatController.title = [HxNickNameImageModel getNickName:conversation.chatter];
    chatController.senderImage = [HxNickNameImageModel getProfileImage:conversation.chatter];
    chatController.hxUserID = conversation.chatter;
    chatController.currentUserImage = GetUserManager().currentUser.currentImage;
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
