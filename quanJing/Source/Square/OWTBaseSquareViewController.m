//
//  OWTBaseSquareViewController.m
//  Weitu
//
//  Created by denghs on 15/11/16.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTBaseSquareViewController.h"
#import "LJFeedWithUserProfileViewCon.h"
#import "ChatListViewController.h"
#import "OWTFeedManager.h"
#import "OWTAppDelegate.h"
#import "OWTMainViewCon.h"
#import "REMenu.h"
#import "RESideMenu.h"
#import "OWTSMSInviteViewCon.h"
#import "OWTTabBarHider.h"
#import "OWTFollowerUsersViewCon.h"
#import "OWTFollowingUsersViewCon.h"
#import "OWTPhotoUploadViewController.h"
#import "OWTImageInfo.h"
#import "OWTPhotoUploadViewController.h"
#import "AGImagePickerController.h"
#import "UIActionSheet+Blocks.h"
#import "OWTAppDelegate.h"
#import "UIBarButtonItem+SHBarButtonItemBlocks.h"
#import "NBUImagePickerController.h"
#import "FAKFontAwesome.h"
#import "MobClick.h"
#import "OWTAssetCollectViewCon.h"
#import "OWTAssetPagingViewCon.h"
#import "WTCommon.h"
#import "REMenu.h"
#import "LJImageAndProfileCell.h"
#import "OWTFeed.h"
#import "XHRefreshControl.h"
#import "SVProgressHUD+WTError.h"
#import <SVPullToRefresh/SVPullToRefresh.h>
#import "OWTAsset.h"
#import "OWTActivity.h"
#import "MJRefresh.h"
#import "LJLike.h"
#import "LJComment.h"
#import "OWTFeedItem.h"
#import "OWTUser.h"
#import "OWTUserInfoEditViewCon.h"
#define IS_WIDESCREEN (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) < DBL_EPSILON)

@interface OWTBaseSquareViewController () <UIImagePickerControllerDelegate,UIActionSheetDelegate>{
    UIView * _headView;
    UIImageView * _redPoint;
    LJFeedWithUserProfileViewCon *_ljvc;
    OWTMainViewCon *_mainViewcon;
    RESideMenu * _sideMenu;
    OWTTabBarHider * _tabBarHider;
    UIButton* _button1;
    UIButton* _button2;
}

@end

@implementation OWTBaseSquareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setUpHeadView];
    [self setupAddButton];
    [self.view addSubview:_mainViewcon.chatListVC.view];
    [self.view addSubview:_ljvc.view];
    _mainViewcon.chatListVC.hidesBottomBarWhenPushed = YES;
}

- (void)setupAddButton
{

    UIButton * left = [LJUIController createButtonWithFrame:CGRectMake(0, 0, 15, 15) imageName:@"选项.png" title:nil target:self action:@selector(showMenu)];
    UIBarButtonItem * btn1 = [[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem = btn1;
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem SH_barButtonItemWithBarButtonSystemItem:UIBarButtonSystemItemAdd withBlock:^(UIBarButtonItem* sender) {
        [self addAndUp];
    }];
}

-(void)setUpPhotoBtn
{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem SH_barButtonItemWithBarButtonSystemItem:UIBarButtonSystemItemAdd withBlock:^(UIBarButtonItem* sender) {
        [self addAndUp];
    }];
}
-(void)setupFentchAddListBtn
{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem SH_barButtonItemWithBarButtonSystemItem:UIBarButtonSystemItemAdd withBlock:^(UIBarButtonItem* sender) {
        [_mainViewcon.chatListVC showAddButton];
    }];
}
- (void)addAndUp
{
    [self createOrUpload];
}

-(void)setup
{
    _tabBarHider = [[OWTTabBarHider alloc] init];
    _ljvc=[[LJFeedWithUserProfileViewCon alloc]initWithNibName:nil bundle:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNewPointStatus:) name:@"setRedPointStatus" object:nil];
    
    if (_ljvc.feed == nil)
    {
        OWTFeed* feed = [GetFeedManager() feedWithID:kWTFeedSquare];
        _ljvc.feed = feed;
    }
    //     hidesBottomBarWhenPushed
    OWTAppDelegate *_delegate = (OWTAppDelegate*)[UIApplication sharedApplication].delegate;
    _mainViewcon = _delegate.mainViewCon;
    [self addChildViewController:_ljvc];
    [self addChildViewController:_mainViewcon.chatListVC];
    
}

// 通过通知中心发送通知

- (void)setNewPointStatus:(NSNotification *)notify
{
    NSNumber * number = (NSNumber *)notify.userInfo;
    OWTAppDelegate *_delegate = (OWTAppDelegate*)[UIApplication sharedApplication].delegate;
    OWTMainViewCon *mainViewcon = _delegate.mainViewCon;
    if ([number boolValue]){
        [_redPoint setHidden:NO];
        [mainViewcon.redPointView setHidden:NO];
    }
    
    else{
        [_redPoint setHidden:YES];
        [mainViewcon.redPointView setHidden:YES];
    }
    
}

- (void)setUpHeadView
{
    _headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 24)];
    
    _button1 = [LJUIController createButtonWithFrame:CGRectMake(0, 0, 50, 24) imageName:@"广场" title:@"广场" target:self action:@selector(guanchangClick:)];
    [_button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _button1.titleLabel.font = [UIFont systemFontOfSize:12];
    _button2 = [LJUIController createButtonWithFrame:CGRectMake(50, 0, 50, 24) imageName:@"消息" title:@"消息" target:self action:@selector(xiaoxiClick:)];
    _button2.titleLabel.font = [UIFont systemFontOfSize:12];
    [_headView addSubview:_button1];
    [_headView addSubview:_button2];
    _redPoint = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"repoint"]];
    _redPoint.frame = CGRectMake(_button2.bounds.size.width - 8 - 5, 0 + 3, 8, 8);
    [_button2 addSubview:_redPoint];
    [_redPoint setHidden:YES];
    NSUserDefaults * userDafault = [NSUserDefaults standardUserDefaults];
    NSNumber * num = [userDafault objectForKey:@"boxNewStatus"];
    
    if ([num boolValue])
        [_redPoint setHidden:NO];
    self.navigationItem.titleView = _headView;
}

- (void)guanchangClick:(UIButton *)sender
{
    [self.view addSubview:_ljvc.view];
    [self setUpPhotoBtn];
    [_button1 setTitle:@"广场" forState:UIControlStateNormal];
    [_button2 setTitle:@"消息" forState:UIControlStateNormal];
    [_button1 setBackgroundImage:[UIImage imageNamed:@"广场"] forState:UIControlStateNormal];
    [_button2 setBackgroundImage:[UIImage imageNamed:@"消息"] forState:UIControlStateNormal];
    [_button1 setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    [_button2 setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [_mainViewcon.chatListVC tapToHidePopView];
}

- (void)xiaoxiClick:(UIButton *)sender
{
    OWTAppDelegate * delegate = (OWTAppDelegate *)[UIApplication sharedApplication].delegate;
    OQJNavCon * hx = delegate.hxChatNavCon;
    [_button1 setTitle:@"广场" forState:UIControlStateNormal];

    [_button2 setTitle:@"消息" forState:UIControlStateNormal];
    [_button1 setBackgroundImage:[UIImage imageNamed:@"消息1"] forState:UIControlStateNormal];
    [_button2 setBackgroundImage:[UIImage imageNamed:@"广场1"] forState:UIControlStateNormal];
    [_button1 setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [_button2 setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    if (hx.viewControllers.count > 0) {
        ChatListViewController * chatlistVC = [hx.viewControllers firstObject];
        [chatlistVC slimeRefreshStartRefresh:nil];
    }
    [self.view addSubview:_mainViewcon.chatListVC.view];
    [self setupFentchAddListBtn];


    

    // 去设置圈子里的红点 － 显示
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setRedPointStatus" object:nil userInfo:(NSDictionary *)[NSNumber numberWithBool:NO]];
}

- (void)showMenu
{
    if (!_sideMenu) {
        RESideMenuItem * message = [[RESideMenuItem alloc] initWithTitle:@"消息" image:[UIImage imageNamed:@"_0002_矢量智能对象"] highlightedImage:[UIImage imageNamed:@"_0002_矢量智能对象"] action:^(RESideMenu * menu, RESideMenuItem * item) {
            [menu hide];
            
            OWTAppDelegate * delegate = (OWTAppDelegate *)[UIApplication sharedApplication].delegate;
            OQJNavCon * hx = delegate.hxChatNavCon;
            
            if (hx.viewControllers.count > 0) {
                ChatListViewController * chatlistVC = [hx.viewControllers firstObject];
                [chatlistVC slimeRefreshStartRefresh:nil];
            }
            [self.view addSubview:_mainViewcon.chatListVC.view];
            [self setupFentchAddListBtn];
        }];
        RESideMenuItem * activityItem = [[RESideMenuItem alloc] initWithTitle:@"我的关注" image:[UIImage imageNamed:@"_0001_矢量智能对象"] highlightedImage:[UIImage imageNamed:@"_0001_矢量智能对象"] action:^(RESideMenu * menu, RESideMenuItem * item) {
            [menu hide];
            [self showFollowings];
        }];
        RESideMenuItem * fans = [[RESideMenuItem alloc] initWithTitle:@"我的粉丝" image:[UIImage imageNamed:@"_0000_矢量智能对象"] highlightedImage:[UIImage imageNamed:@"_0000_矢量智能对象象"] action:^(RESideMenu * menu, RESideMenuItem * item) {
            [menu hide];
            [self showFollowers];
            
            NSLog(@"Item %@", item);
        }];
        RESideMenuItem * invitePee = [[RESideMenuItem alloc] initWithTitle:@"邀请好友" image:[UIImage imageNamed:@"_0005_矢量智能对象"] highlightedImage:[UIImage imageNamed:@"_0005_矢量智能对象"] action:^(RESideMenu * menu, RESideMenuItem * item) {
            [menu hide];
            [self presentSMSInvite];
            
            NSLog(@"Item %@", item);
        }];
        
        _sideMenu = [[RESideMenu alloc] initWithItems:@[message, activityItem, fans, invitePee]];
        _sideMenu.verticalOffset = IS_WIDESCREEN ? 250 : 76;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapProfileImage:)];
        [_sideMenu.profileView addGestureRecognizer:tap];
        
        // _sideMenu.hideStatusBarArea = [self OSVersion] < 7;
    }
    
    [_sideMenu show];
}

- (void)onTapProfileImage:(UIGestureRecognizer *)sender
{
//    [_sideMenu hide]; 微 你要是觉得有眼缘 可以哪天约你 吃饭聊聊或看个电影吧
//    OWTUser * userme = GetUserManager().currentUser;
//    
//    if (userme != nil) {
//        if (_userViewCon1) {
//            [_userViewCon1 adealloc];
//            _userViewCon1 = nil;
//        }
//        _userViewCon1 = [[OWTUserViewCon alloc] initWithNibName:nil bundle:nil];
//        _userViewCon1.hidesBottomBarWhenPushed = YES;
//        _userViewCon1.ifFirstEnter = YES;
//        _userViewCon1.rightTriggle = YES;
//        __weak __typeof( & * self) weakSelf = self;
//        
//        [weakSelf.navigationController pushViewController:_userViewCon1 animated:YES];
//        _userViewCon1.user = userme;
//    }
}


- (void)presentSMSInvite
{
    
    OWTSMSInviteViewCon * ovc = [[OWTSMSInviteViewCon alloc]init];
    
    ovc.hidesBottomBarWhenPushed = YES;
    [_tabBarHider hideTabBar];
    
    [self.navigationController pushViewController:ovc animated:YES];
}

- (void)showFollowings
{
    OWTFollowingUsersViewCon * followingUsersViewCon = [[OWTFollowingUsersViewCon alloc] initWithNibName:nil bundle:nil];
    
    //    followingUsersViewCon.user = _user;
    followingUsersViewCon.hidesBottomBarWhenPushed = YES;
    [_tabBarHider hideTabBar];
    [self.navigationController pushViewController:followingUsersViewCon animated:YES];
}

- (void)showFollowers
{
    OWTFollowerUsersViewCon * followerUsersViewCon = [[OWTFollowerUsersViewCon alloc] initWithNibName:nil bundle:nil];
    
    //    followerUsersViewCon.user = _user;
    followerUsersViewCon.hidesBottomBarWhenPushed = YES;
    [_tabBarHider hideTabBar];
    [self.navigationController pushViewController:followerUsersViewCon animated:YES];
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
                 onClickedButton:^(UIActionSheet * actionSheet, NSUInteger buttonIndex) {
                     if (buttonIndex == 0)
                         [self takePhontos1];
                     else if (buttonIndex == 1)
                         [self uploadPhotosWithFilteredGroupNames:[NSSet setWithObject:@"全景"]];
                     //                     else if (buttonIndex == 2)
                     //                     {
                     //                         [self uploadPhotosLocal];
                     //                         [self createAlbum];
                     //                     }
                 }];
}

- (void)takePhontos1
{
    __weak OWTBaseSquareViewController *wself = self;
    UIImagePickerController * controller = [[UIImagePickerController alloc] init];
    
    [controller setSourceType:UIImagePickerControllerSourceTypeCamera];		// 设置类型
    
    // 设置所支持的类型，设置只能拍照，或则只能录像，或者两者都可以
    NSString * requiredMediaType = (NSString *)kUTTypeImage;
    NSString * requiredMediaType1 = (NSString *)kUTTypeMovie;
    NSArray * arrMediaTypes = [NSArray arrayWithObjects:requiredMediaType, nil];
    [controller setMediaTypes:arrMediaTypes];
    
    // 设置录制视频的质量
    //        [controller setVideoQuality:UIImagePickerControllerQualityTypeHigh];
    // 设置最长摄像时间
    //        [controller setVideoMaximumDuration:10.f];
    
    //        [controller setAllowsEditing:YES];// 设置是否可以管理已经存在的图片或者视频
    [controller setDelegate:self];		// 设置代理
    [self.navigationController presentViewController:controller animated:NO completion:^{}];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"Picker returned successfully.");
    NSLog(@"%@", info);
    NSString * mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    // 判断获取类型：图片
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage * theImage = nil;
        
        // 判断，图片是否允许修改
        if ([picker allowsEditing])
            // 获取用户编辑之后的图像
            theImage = [info objectForKey:UIImagePickerControllerEditedImage];
        else
            // 照片的元数据参数
            theImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(theImage, self, nil, nil);
        NSMutableArray * imageInfos = [[NSMutableArray alloc] init];
        OWTImageInfo * imageInfo = [[OWTImageInfo alloc] init];
        imageInfo.image = theImage;
        [imageInfos addObject:imageInfo];
        OWTPhotoUploadViewController * photoUploadVC = [[OWTPhotoUploadViewController alloc] initWithNibName:nil bundle:nil];
        photoUploadVC.imageInfos = imageInfos;
        photoUploadVC.hidesBottomBarWhenPushed = YES;
        photoUploadVC.isCameraImages = YES;
        photoUploadVC.cancelAction = ^{
            [self.navigationController popViewControllerAnimated:YES];
        };
        
        photoUploadVC.doneAction = ^{
            [self.navigationController popViewControllerAnimated:YES];
        };
        [self.navigationController pushViewController:photoUploadVC animated:NO];
    }
    
    [picker dismissViewControllerAnimated:nil completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:nil completion:nil];
}

- (void)uploadPhotosWithFilteredGroupNames:(NSSet *)filteredGroupNames
{
    __weak __typeof(self) weakSelf = self;
    
    AGImagePickerController * imagePickerController = [[AGImagePickerController alloc] initWithFailureBlock:^(NSError * error) {
        if (error == nil) {
            NSLog(@"User has cancelled.");
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            });
        }
    } andSuccessBlock:^(NSArray * info) {
        NSLog(@"Info: %@", info);
        NSMutableArray * imageInfos = [NSMutableArray arrayWithCapacity:info.count];
        
        for (ALAsset * mediaInfo in info) {
            NSLog(@"Info: %@", mediaInfo);
            
            OWTImageInfo * imageInfo = [[OWTImageInfo alloc] init];
            
            imageInfo.url = [[mediaInfo valueForProperty:ALAssetPropertyAssetURL] absoluteString];
            
            imageInfo.primaryColorHex = @"DDDDDD";
            imageInfo.width = 64;
            imageInfo.height = 64;
            imageInfo.asset = mediaInfo;
            [imageInfos addObject:imageInfo];
        }
        
        [weakSelf dismissViewControllerAnimated:NO
                                     completion:^{
                                         OWTPhotoUploadViewController * photoUploadVC = [[OWTPhotoUploadViewController alloc] initWithNibName:nil bundle:nil];
                                         photoUploadVC.hidesBottomBarWhenPushed = YES;
                                         photoUploadVC.imageInfos = imageInfos;
                                         photoUploadVC.isCameraImages = NO;
                                         photoUploadVC.doneAction = ^{
                                             [weakSelf.navigationController popViewControllerAnimated:YES];
                                         };
                                         photoUploadVC.cancelAction = ^{
                                             [weakSelf.navigationController popViewControllerAnimated:YES];
                                         };
                                         
                                         [weakSelf.navigationController pushViewController:photoUploadVC animated:YES];
                                     }];
    }];
    
    imagePickerController.shouldShowSavedPhotosOnTop = YES;
    //    imagePickerController.shouldChangeStatusBarStyle = YES;
    //    imagePickerController.selection = self.selectedPhotos;
    imagePickerController.maximumNumberOfPhotosToBeSelected = 9;
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
    
    // modified by springox(20140503)
    [imagePickerController showFirstAssetsController];
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
