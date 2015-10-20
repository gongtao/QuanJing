//
//  LJExploreSquareController.m
//  Weitu
//
//  Created by qj-app on 15/9/1.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJExploreSquareController.h"
#import "LJImageAndProfileCell.h"
#import "OWTFeed.h"
#import "XHRefreshControl.h"
#import "SVProgressHUD+WTError.h"
#import <SVPullToRefresh/SVPullToRefresh.h>
#import "OWTTabBarHider.h"
#import "OWTAsset.h"
#import "OWTActivity.h"
#import "MJRefresh.h"
#import "LJLike.h"
#import "LJComment.h"
#import "OWTAssetCollectViewCon.h"
#import "OWTAssetPagingViewCon.h"
#import "OWTUserViewCon.h"
#import "OWTFeedItem.h"
#import "WTCommon.h"
#import "OWTUser.h"
#import "OWTUserManager.h"
#import "AGImagePickerController.h"
#import "UIBarButtonItem+SHBarButtonItemBlocks.h"
#import "OWTPhotoUploadInfoViewCon.h"
#import "OWTUserInfoEditViewCon.h"
#import "NetStatusMonitor.h"
#import "UIActionSheet+Blocks.h"
#import "NBUImagePickerController.h"
#import "REMenu.h"
#import "FAKFontAwesome.h"
#import "OQJNavCon.h"
#import "OWTAppDelegate.h"
#import "OWTSMSInviteViewCon.h"
#import "OWTFollowerUsersViewCon.h"
#import "OWTFollowingUsersViewCon.h"
#import "ChatListViewController.h"
#import "OWTFeedManager.h"
#import "LJExploreCell.h"
@interface LJExploreSquareController ()<UITableViewDelegate,UITableViewDataSource,XHRefreshControlDelegate,UIAlertViewDelegate>


@end

@implementation LJExploreSquareController
{
    UITableView *_tableView;
    
    OWTTabBarHider *_tabBarHider;
    //XHRefreshControl *_refreshControl;
    UIView *_backgroundView;
    UITextField *_textField;
    UIButton *_sendButton;
    UIImageView *_imageView;
    OWTActivityData *_activityData;
    NSInteger _pageNum;
    NSInteger _allNum;
    NSInteger _scrolly;
    LJExploreCell *_cell;
    OWTUser *_user;
    BOOL isFirst;
    NSInteger _imageNum;
    REMenu *_feedMenu;
    OWTUserViewCon* _userViewCon1;
    NSMutableArray *_customViews;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setup];
        _heights=[[NSMutableArray alloc]init];
        _imageNum=0;
    }
    return self;
}
- (instancetype)initWithGameId:(NSString *)GameId withTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        _feed=[[OWTFeed alloc]initWithFeedInfo:nil];
        self.title=title;
        _feed.gameId=GameId;
        [self setup];
        _heights=[[NSMutableArray alloc]init];
        _imageNum=0;
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    _user=GetUserManager().currentUser;
    //    if (_user.nickname.length==0) {
    //        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"请先完善个人信息" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    //        [alert show];
    //    }
//    if (_assets.count==0) {
//        [_feed getResouceWithSuccess2:^{
//            [self getResourceData];
//        }];
//    }
//    if (isFirst) {
//        [_feed getResouceWithSuccess2:^{
//            [self getResourceData];
//        }];}
//    isFirst=NO;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        OWTUserInfoEditViewCon* userInfoEditViewCon = [[OWTUserInfoEditViewCon alloc] initWithNibName:nil bundle:nil];
        userInfoEditViewCon.user = _user;
        
        userInfoEditViewCon.cancelAction = ^{
            //            [self dismissViewControllerAnimated:YES completion:nil];
        };
        
        userInfoEditViewCon.doneFunc = ^{
            [_tableView reloadData];
            //            [self dismissViewControllerAnimated:YES completion:^{
            
            //            }];
        };
        
        UINavigationController* navCon = [[UINavigationController alloc] initWithRootViewController:userInfoEditViewCon];
        //        [self presentViewController:navCon animated:YES completion:nil];
        [_tabBarHider hideTabBar];
        [self.navigationController pushViewController:userInfoEditViewCon animated:YES];
    }
    
}
-(void)setup
{
    _tabBarHider = [[OWTTabBarHider alloc] init];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    isFirst=YES;
    _assets=[[NSMutableArray alloc]init];
    _comment=[[NSMutableArray alloc]init];
    _likes=[[NSMutableArray alloc]init];
    _heights=[[NSMutableArray alloc]init];
    self.view.backgroundColor = GetThemer().themeColorBackground;
    [self setupTableView];
    // [self setupRefreshControl];
    [self setupRefresh];
    _cell=[[LJExploreCell alloc]init];
    [_tableView reloadData];
    [self setupAddButton];
//    [self setupNavMenu];
}
- (void)setupNavMenu
{
    _customViews=[[NSMutableArray alloc]init];
    NSArray *title=@[@"消息",@"我的关注",@"我的粉丝",@"邀请好友"];
    for (NSInteger i=0; i<4; i++) {
        UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, 40)];
        view.backgroundColor=[UIColor whiteColor];
        UILabel *label=[LJUIController createLabelWithFrame:CGRectMake(30, 12.5, 100, 15) Font:12 Text:title[i]];
        [view addSubview:label];
        UIImageView *imageVIEW1=[LJUIController createImageViewWithFrame:CGRectMake(SCREENWIT-30, 12.5, 10, 15) imageName:@"首页18-1_05.png"];
        [view addSubview:imageVIEW1];
        [_customViews addObject:view];
    }
    REMenuItem *_homeItem=[[REMenuItem alloc]initWithCustomView:_customViews[0] action:^(REMenuItem *item) {
        OWTAppDelegate *delegate = (OWTAppDelegate*)[UIApplication sharedApplication].delegate;
        
        
        OQJNavCon *hx = delegate.hxChatNavCon;
        if (hx.viewControllers.count>0) {
            ChatListViewController *chatlistVC = [hx.viewControllers firstObject];
            [chatlistVC slimeRefreshStartRefresh:nil];
        }
        [self presentViewController:hx animated:YES completion:nil];    }];
    
    REMenuItem* latestItem = [[REMenuItem alloc]initWithCustomView:_customViews[1] action:^(REMenuItem *item) {
        [self showFollowings];
        
    }];
    REMenuItem* wallpaperItem = [[REMenuItem alloc]initWithCustomView:_customViews[2] action:^(REMenuItem *item) {
        [self showFollowers];
    }];
    REMenuItem* followingItem = [[REMenuItem alloc]initWithCustomView:_customViews[3] action:^(REMenuItem *item) {
        [self presentSMSInvite];
    }];
    
    _feedMenu = [[REMenu alloc] initWithItems:@[ _homeItem, latestItem, wallpaperItem, followingItem]];
    _feedMenu.liveBlur = YES;
    _feedMenu.liveBlurBackgroundStyle = REMenuLiveBackgroundStyleLight;
    _feedMenu.closeOnSelection = YES;
    _feedMenu.itemHeight=40;
    _feedMenu.font = [UIFont boldSystemFontOfSize:16];
    _feedMenu.textOffset = CGSizeMake(0, 2);
    _feedMenu.textColor = [UIColor darkGrayColor];
    _feedMenu.subtitleFont = [UIFont systemFontOfSize:13];
    _feedMenu.subtitleTextColor = [UIColor darkGrayColor];
    _feedMenu.subtitleTextOffset = CGSizeMake(0, -1);
    _feedMenu.subtitleTextShadowColor = nil;
    _feedMenu.borderWidth = 0.5;
    _feedMenu.borderColor = [UIColor lightGrayColor];
    _feedMenu.separatorColor = [UIColor lightGrayColor];
    _feedMenu.separatorHeight = 0.5;
    
    _feedMenu.highlightedTextShadowColor = nil;
    _feedMenu.highlightedTextColor = [UIColor blackColor];
    _feedMenu.subtitleHighlightedTextColor = [UIColor blackColor];
    _feedMenu.subtitleHighlightedTextShadowColor = nil;
    _feedMenu.highlightedBackgroundColor = GetThemer().themeColor;
    
    _feedMenu.cornerRadius = 4;
    
    _feedMenu.imageOffset = CGSizeMake(10, 0);
    _feedMenu.waitUntilAnimationIsComplete = NO;
    
    __weak typeof (*self) * weakSelf = self;
    _feedMenu.closeCompletionHandler = ^{
        weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
    };
}



- (void)setupAddButton
{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem SH_barButtonItemWithBarButtonSystemItem:UIBarButtonSystemItemAdd withBlock:^(UIBarButtonItem* sender) {
        [self createOrUpload];
    }];
//    UIButton *left=[LJUIController createButtonWithFrame:CGRectMake(0, 0, 15, 15) imageName:@"圈子.png" title:nil target:self action:@selector(cehuaClick)];
//    UIBarButtonItem *btn1=[[UIBarButtonItem alloc]initWithCustomView:left];
//    self.navigationItem.leftBarButtonItem=btn1;
}
-(void)cehuaClick
{
    if (_feedMenu.isOpen)
    {
        return [_feedMenu close];
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [_feedMenu showFromNavigationController:self.navigationController];
    
}
- (void)createOrUpload
{
    [UIActionSheet presentOnView:[self.view window]
                       withTitle:nil
                    cancelButton:@"取消"
               destructiveButton:nil
     //                    otherButtons:@[@"拍照", @"发布图片", @"创建相册"]
                    otherButtons:@[@"拍照", @"发布图片"]
                        onCancel:nil
                   onDestructive:nil
                 onClickedButton:^(UIActionSheet* actionSheet, NSUInteger buttonIndex) {
                     if (buttonIndex == 0)
                     {
                         [self takePhontos];
                     }
                     else if (buttonIndex == 1)
                     {
                         [self uploadPhotosWithFilteredGroupNames:[NSSet setWithObject:@"全景"]];
                     }
                     //                     else if (buttonIndex == 2)
                     //                     {
                     //                         [self uploadPhotosLocal];
                     //                         [self createAlbum];
                     //                     }
                 }];
}
-(void)takePhontos{
    //    [_popoverViewCon dismissPopoverAnimated:NO];
    
    
    NBUImagePickerResultBlock resultBlock = ^(NSArray* images)
    {
        if (images == nil || images.count == 0)
        {
            return;
        }
        else
        {
            OWTPhotoUploadInfoViewCon* photoUploadInfoViewCon = [[OWTPhotoUploadInfoViewCon alloc] initWithDefaultStyle];
            photoUploadInfoViewCon.Name=self.title;
            [self.navigationController pushViewController:photoUploadInfoViewCon animated:NO];
            
            [photoUploadInfoViewCon setPendingUploadImages:images];
            photoUploadInfoViewCon.doneAction = ^{
                [_tabBarHider showTabBar];
            };
        }
    };
    
    NBUImagePickerOptions options = NBUImagePickerOptionSingleImage |
    NBUImagePickerOptionReturnImages |
    NBUImagePickerOptionStartWithCamera |
    NBUImagePickerOptionDisableEdition |
    NBUImagePickerOptionDisableLibrary |
    NBUImagePickerOptionDoNotSaveImages;
    
    [NBUImagePickerController startPickerWithTarget:self
                                            options:options
                                   customStoryboard:nil
                                        resultBlock:resultBlock];
};

- (void)uploadPhotosWithFilteredGroupNames:(NSSet*)filteredGroupNames
{
    AGImagePickerController *imagePickerController = [[AGImagePickerController alloc] initWithFailureBlock:^(NSError *error) {
        if (error == nil)
        {
            NSLog(@"User has cancelled.");
            [self dismissModalViewControllerAnimated:YES];
        } else
        {
            NSLog(@"Error: %@", error);
            
            // Wait for the view controller to show first and hide it after that
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self dismissModalViewControllerAnimated:YES];
            });
        }
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        
    } andSuccessBlock:^(NSArray *info) {
        
        NSMutableArray* imageInfos = [NSMutableArray arrayWithCapacity:info.count];
        for (ALAsset* mediaInfo in info)
        {
            OWTImageInfo* imageInfo = [[OWTImageInfo alloc] init];
            imageInfo.url =[[mediaInfo valueForProperty:ALAssetPropertyAssetURL] absoluteString];
            
            imageInfo.primaryColorHex = @"DDDDDD";
            imageInfo.width = 64;
            imageInfo.height = 64;
            [imageInfos addObject:imageInfo];
        }
        [self dismissModalViewControllerAnimated:YES];
        OWTPhotoUploadInfoViewCon* photoUploadInfoViewCon = [[OWTPhotoUploadInfoViewCon alloc] initWithDefaultStyle];
        photoUploadInfoViewCon.Name=self.title;
        photoUploadInfoViewCon.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:photoUploadInfoViewCon animated:NO];
        [photoUploadInfoViewCon setPendingUploadImageInfos:imageInfos];
        
        
        photoUploadInfoViewCon.doneAction = ^{
            [self dismissModalViewControllerAnimated:YES];
        };
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }];
    
    imagePickerController.shouldShowSavedPhotosOnTop = YES;
    imagePickerController.shouldChangeStatusBarStyle = YES;
    //    imagePickerController.selection = self.selectedPhotos;
    imagePickerController.maximumNumberOfPhotosToBeSelected = 9;
    
    
    [self presentModalViewController:imagePickerController animated:YES];
    
    
    // modified by springox(20140503)
    [imagePickerController showFirstAssetsController];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setupTableView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    _backgroundView=[[UIView alloc]initWithFrame:self.view.frame];
    _backgroundView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    [self.view addSubview:_backgroundView];
    [self.view sendSubviewToBack:_backgroundView];
    UITapGestureRecognizer *backTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onBackTap)];
    _imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, 45)];
    _imageView.userInteractionEnabled=YES;
    _imageView.backgroundColor=[UIColor whiteColor];
    [_backgroundView addSubview:_imageView];
    _textField=[[UITextField alloc]initWithFrame:CGRectMake(10, 5, SCREENWIT-90, 34)];
    _textField.borderStyle=UITextBorderStyleRoundedRect;
    
    [_imageView addSubview:_textField];
    _sendButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_sendButton setBackgroundImage:[UIImage imageNamed:@"b3.png"] forState:UIControlStateNormal];
    [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_sendButton setFrame:CGRectMake(SCREENWIT-70, 5, 60, 34)];
    [_sendButton addTarget:self action:@selector(onSendBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_imageView addSubview:_sendButton];
    [_backgroundView addGestureRecognizer:backTap];
    CGRect frame=self.view.frame;
    frame.size.height=frame.size.height-64;
    _tableView=[[UITableView alloc]initWithFrame:frame];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
}
-(void)onBackTap
{
    [self.view sendSubviewToBack:_backgroundView];
    _replyid=nil;
    _textField.placeholder=nil;
    [_textField resignFirstResponder];
}
-(void)onSendBtn:(UIButton *)sender
{
    OWTUser *user=GetUserManager().currentUser;
    RKObjectManager *um=[RKObjectManager sharedManager];
    NSArray *arr=[_textField.text componentsSeparatedByString:@" "];
    BOOL ret=NO;
    for (NSString *str in arr) {
        if (![str isEqualToString:@""]) {
            ret=YES;
        }
    }
    if (_textField.text!=nil&&_textField.text.length!=0&&ret) {
        NSMutableArray *comments=_comment[_pageNum];
        LJComment *ljcomment=[[LJComment alloc]init];
        ljcomment.activityId=_activityData.commentid;
        ljcomment.content=_textField.text;
        ljcomment.userid=user.userID;
        if (_replyid.length!=0) {
            ljcomment.replyuserid=_replyid;
        }
        else{
            ljcomment.replyuserid=@"0";
        }
        [comments addObject:ljcomment];
        [_comment replaceObjectAtIndex:_pageNum withObject:comments];
        NSString *str;
        CGFloat imageHeight=(SCREENWIT-100)/9;
        CGFloat x=SCREENWIT-10-imageHeight;
        if (_replyid.length!=0) {
            str=[NSString stringWithFormat:@"%@%@%@   ",_replyid,_textField.text,user.userID];
        }else
        {
            str=[NSString stringWithFormat:@"%@%@ ",_textField.text,user.userID];
        }
        CGSize size=[str sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(x, 500)];
        NSString *h=_heights[_pageNum];
        NSString *he;
        float commentHeight=0;
        commentHeight=size.height>imageHeight?size.height:imageHeight;
        if (comments.count==1) {
            he=[NSString stringWithFormat:@"%f",h.floatValue+commentHeight+10];
        }else {
            he=[NSString stringWithFormat:@"%f",h.floatValue+commentHeight+5];
        }
        [_heights replaceObjectAtIndex:_pageNum withObject:he];
        [self reloadData:_pageNum];
        
        if (_replyid.length!=0) {
            [um postObject:nil path:@"activity/comment" parameters:@{@"Activityid":_activityData.commentid,@"Content":_textField.text,@"Replyuserid":_replyid} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            }
                   failure:^(RKObjectRequestOperation *operation, NSError *error) {
                       
                   }];
        }
        else{
            [um postObject:nil path:@"activity/comment" parameters:@{@"Activityid":_activityData.commentid,@"Content":_textField.text} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            }
                   failure:^(RKObjectRequestOperation *operation, NSError *error) {
                       
                   }];
            
        }}
    [_textField resignFirstResponder];
    _textField.text=nil;
    [self.view sendSubviewToBack:_backgroundView];
}
-(void)inputKeyboardWillShow:(NSNotification *)notification
{
    CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animationTime animations:^{
        CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        _imageView.frame=CGRectMake(0, SCREENHEI-keyBoardFrame.size.height-45-64, SCREENWIT, 45);
        if (_replyid.length!=0) {
            _textField.placeholder=[NSString stringWithFormat:@"回复 %@",[self getTheNickname:_replyid  withUser:_feed.userInformations]];
        }else
        {
            _textField.placeholder=nil;
        }
    }];
    
}

-(NSString *)getTheNickname:(NSString *)userid withUser:(NSArray *)users
{
    for (OWTUser *user in users) {
        if ([userid isEqualToString:user.userID]) {
            return [NSString stringWithFormat:@"%@",user.nickname];
        }
    }
    return nil;
}


-(void)getResourceData
{
    [_assets removeAllObjects];
    [_likes removeAllObjects];
    [_comment removeAllObjects];
    for (OWTActivityData *activity in _feed.activitiles) {
        NSArray *subjectAssetIDs=[activity.subjectAssetID componentsSeparatedByString:@","];
        NSMutableArray *assets=[[NSMutableArray alloc]init];
        NSMutableArray *comments=[NSMutableArray arrayWithCapacity:0];
        NSMutableArray *likes=[NSMutableArray arrayWithCapacity:0];
        for (NSString *assetNum in subjectAssetIDs) {
            
            for (OWTAsset *asset in _feed.items) {
                if ([assetNum isEqualToString:asset.assetID]) {
                    [assets addObject:asset];
                    break;
                }
            }
            
        }
        for (LJLike *like in _feed.activLike) {
            if ([like.activityid isEqualToString:activity.commentid]) {
                [likes addObject:like];
            }
        }
        for (LJComment *comment in _feed.activComment) {
            if ([comment.activityId isEqualToString:activity.commentid]) {
                [comments addObject:comment];
            }
        }
        [_likes addObject:likes];
        [_assets addObject:assets];
        [_comment addObject:comments];
    }
    _heights=(NSMutableArray *)[_cell getTheAllCellHeight:_assets withUserInformation:_feed.userInformations withLike:_likes withComment:_comment withActivityData:_feed.activitiles];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfItems];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *identifier=@"LJQuanjingCell";
    LJExploreCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[LJExploreCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier withViewController:self withComment:^(OWTActivityData *activity,NSInteger pageNum){
            _activityData=activity;
            _pageNum=pageNum;
            [self.view bringSubviewToFront:_backgroundView];
            [_textField becomeFirstResponder];
        }];        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    else{
        for (UIView *view in cell.contentView.subviews) {
            if (view.tag==201||(view.tag>=400&&view.tag<420)||(view.tag>=500)) {
                [view removeFromSuperview];
            }
            if ([view isKindOfClass:[UIScrollView class]]) {
                for (UIView *view1 in view.subviews) {
                    [view1 removeFromSuperview];
                }
            }
        }
    }
    OWTActivityData *activity=_feed.activitiles[indexPath.row];
    NSString* ownerUserID = activity.userID;
    cell.headerImagecb = ^{
        
        OWTUser* ownerUser = [GetUserManager() userForID:ownerUserID];
        //OWTUser *ownerUser=[self userAtIndexPath:indexPath];
        if (ownerUser != nil)
        {
            
            if(_userViewCon1){
                [_userViewCon1 adealloc];
                _userViewCon1 = nil;
            }
            _userViewCon1 = [[OWTUserViewCon alloc] initWithNibName:nil bundle:nil];
            _userViewCon1.hidesBottomBarWhenPushed = YES;
            _userViewCon1.ifFirstEnter = YES;
            _userViewCon1.rightTriggle = YES;
            __weak __typeof(&*self)weakSelf = self;
            [weakSelf.navigationController pushViewController:_userViewCon1 animated:YES];
            _userViewCon1.user =ownerUser;
            
            
        }
    };
    
    cell.number=indexPath.row;
    [cell customCell:_assets[indexPath.row] withUserInformation:_feed.userInformations withLike:_likes[indexPath.row] withComment:_comment[indexPath.row] withActivityData:_feed.activitiles[indexPath.row] withImageNumber:_imageNum];
    _imageNum=0;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str=_heights[indexPath.row];
    return str.floatValue;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _allNum=_feed.activitiles.count;
    if (scrollView==_tableView) {
        _scrolly=scrollView.contentOffset.y;
    }
    
    
}
#pragma mark 关于OWTFeed
-(NSInteger)numberOfItems
{
    return _feed.activitiles.count;
}
-(OWTUser *)userAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *users=_feed.userInformations;
    OWTActivityData *activityData=_feed.activitiles[indexPath.row];
    for (OWTUser *user in users) {
        if ([activityData.userID isEqualToString:user.userID]) {
            return user;
        }
    }
    return nil;
}

- (OWTFeedItem*)itemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_feed != nil && indexPath != nil)
    {
        NSInteger row = indexPath.row;
        if (row < _feed.items.count)
        {
            return _feed.items[row];
        }
    }
    
    return nil;
}
- (void)presentFeed:(OWTFeed*)feed animated:(BOOL)animated refresh:(BOOL)refresh
{
    if (feed == _feed)
    {
        if (refresh)
        {
            
        }
        return;
    }
    
    if (_feed == nil)
    {
        self.view.alpha = 0.0;
        _feed = feed;
        if (refresh)
        {
            [_tableView reloadData];
            
        }
        else
        {
            [_tableView reloadData];
        }
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.view.alpha = 1.0;
                         }
                         completion:nil];
    }
    else
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.view.alpha = 0.0;
                         }
                         completion:^(BOOL isFinished) {
                             _feed = feed;
                             if (refresh)
                             {
                                 [_tableView reloadData];
                             }
                             else
                             {
                                 [_tableView reloadData];
                             }
                             [UIView animateWithDuration:0.3
                                              animations:^{
                                                  self.view.alpha = 1.0;
                                              }
                                              completion:nil];
                         }];
    }
}
#pragma mark 刷新数据
- (void)setupRefresh
{
    //下拉刷新
    [_tableView addHeaderWithTarget:self action:@selector(refreshFeed) dateKey:@"table"];
    [_tableView headerBeginRefreshing];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [_tableView addFooterWithTarget:self action:@selector(loadMoreFeedItems)];
    //一些设置
    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
    _tableView.headerPullToRefreshText = @"";
    _tableView.headerReleaseToRefreshText = @"";
    _tableView.headerRefreshingText = @"";
    
    _tableView.footerPullToRefreshText = @"";
    _tableView.footerReleaseToRefreshText = @"";
    _tableView.footerRefreshingText = @"";
}


- (void)loadMoreFeedItems
{
    [_feed loadMoreWithSuccess2:^{
        [self getResourceData];
        [_tableView reloadData];
        [_tableView footerEndRefreshing];
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_allNum-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
                        failure:^(NSError* error) {
                            [_tableView footerEndRefreshing];
                            if (![NetStatusMonitor isExistenceNetwork]) {
                                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
                                return ;
                            }
                            else{
                                [SVProgressHUD showError:error];
                            }
                            
                            
                        }];
}


-(void)reloadData:(NSInteger)page
{
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:page inSection:0];
    NSArray *arr=[NSArray arrayWithObject:indexPath];
    [_tableView reloadRowsAtIndexPaths:arr withRowAnimation:NO];
}

- (void)refreshFeed
{
    [_feed refreshWithSuccess2:^{
        [self getResourceData];
        [_tableView reloadData];
        [_tableView headerEndRefreshing];
    }
                       failure:^(NSError* error) {
                           [_tableView headerEndRefreshing];
                           if (![NetStatusMonitor isExistenceNetwork]) {
                               [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
                               return ;
                           }
                           [SVProgressHUD showError:error];
                       }];
}


#pragma mark scroll delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_tabBarHider notifyScrollViewWillBeginDraggin:scrollView];
}

#pragma mark XHRefresh  Delegate

-(void)dealloc
{
    _tableView.delegate=nil;
    _tableView.dataSource=nil;
    
}
-(void)presentSMSInvite
{
    
    OWTSMSInviteViewCon *ovc=[[OWTSMSInviteViewCon alloc]init];
    ovc.hidesBottomBarWhenPushed=YES;
    [_tabBarHider hideTabBar];
    
    [self.navigationController pushViewController:ovc animated:YES];
    
}
- (void)showFollowings
{
    OWTFollowingUsersViewCon* followingUsersViewCon = [[OWTFollowingUsersViewCon alloc] initWithNibName:nil bundle:nil];
    followingUsersViewCon.user = _user;
    followingUsersViewCon.hidesBottomBarWhenPushed=YES;
    [_tabBarHider hideTabBar];
    [self.navigationController pushViewController:followingUsersViewCon animated:YES];
}

- (void)showFollowers
{
    OWTFollowerUsersViewCon* followerUsersViewCon = [[OWTFollowerUsersViewCon alloc] initWithNibName:nil bundle:nil];
    followerUsersViewCon.user = _user;
    followerUsersViewCon.hidesBottomBarWhenPushed=YES;
    [_tabBarHider hideTabBar];
    [self.navigationController pushViewController:followerUsersViewCon animated:YES];
}
@end
