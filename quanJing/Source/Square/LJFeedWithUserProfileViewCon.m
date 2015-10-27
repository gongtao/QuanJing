//
//  LJFeedWithUserProfileViewCon.m
//  Weitu
//
//  Created by qj-app on 15/5/20.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJFeedWithUserProfileViewCon.h"
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
#import "OWTAuthManager.h"
#import "RESideMenu.h"
#import "UIColor+HexString.h"
#import "OWTPhotoUploadViewController.h"
#import "QuanJingSDK.h"
#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )


@interface LJFeedWithUserProfileViewCon ()<UITableViewDelegate,UITableViewDataSource,XHRefreshControlDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate>

@end

@implementation LJFeedWithUserProfileViewCon
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
    LJImageAndProfileCell *_cell;
    OWTUser *_user;
    BOOL isFirst;
    NSInteger _imageNum;
    REMenu *_feedMenu;
    OWTUserViewCon* _userViewCon1;
    NSMutableArray *_customViews;
    RESideMenu *_sideMenu;
    UIView *_headView;
    NSNumber *_cuIndex;
    
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
-(void)viewWillAppear:(BOOL)animated
{
    _user=GetUserManager().currentUser;
//    if (_user.nickname.length==0) {
//        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"请先完善个人信息" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
//        [alert show];
//    }
        if (isFirst) {
        [_feed getResouceWithSuccess:^{
            [self getResourceData];
        }];}
    [UIApplication sharedApplication].statusBarStyle=UIStatusBarStyleLightContent;
    [_tabBarHider showTabBar];
    isFirst=NO;

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
    [self setUpData];
    self.view.backgroundColor = GetThemer().themeColorBackground;
    [self setupTableView];
    // [self setupRefreshControl];
    [self setupRefresh];
    _cell=[[LJImageAndProfileCell alloc]init];
    [_tableView reloadData];
    [self setupAddButton];
    [self setUpHeadView];
//    [self setupNavMenu];
}
-(void)setUpData
{
    _assets=[[NSMutableArray alloc]init];
    _comment=[[NSMutableArray alloc]init];
    _likes=[[NSMutableArray alloc]init];
    _heights=[[NSMutableArray alloc]init];
    _activeList=[[NSMutableArray alloc]init];
    _cuIndex=[[NSNumber alloc]init];
}
- (void)setupAddButton
{
//    self.navigationItem.rightBarButtonItem = [UIBarButtonItem SH_barButtonItemWithBarButtonSystemItem:UIBarButtonSystemItemAdd withBlock:^(UIBarButtonItem* sender) {
//        [self createOrUpload];
//    }];
    UIButton *left=[LJUIController createButtonWithFrame:CGRectMake(0, 0, 15, 15) imageName:@"选项.png" title:nil target:self action:@selector(showMenu)];
    UIBarButtonItem *btn1=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=btn1;
    UIButton *right=[LJUIController createButtonWithFrame:CGRectMake(0, 0, 20, 15) imageName:@"_0008_加号.png" title:nil target:self action:@selector(addAndUp)];
    UIBarButtonItem *btn2=[[UIBarButtonItem alloc]initWithCustomView:right];
    self.navigationItem.rightBarButtonItem=btn2;

//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTheTableView) name:@"refreshFeed" object:nil];
}
-(void)setUpHeadView
{
    _headView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 24)];
    
    UIButton *button1=[LJUIController createButtonWithFrame:CGRectMake(0, 0,50 , 24) imageName:@"广场" title:@"广场" target:self action:@selector(guanchangClick:)];
    [button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button1.titleLabel.font=[UIFont systemFontOfSize:12];
    UIButton *button2=[LJUIController createButtonWithFrame:CGRectMake(50, 0, 50, 24) imageName:@"消息" title:@"消息" target:self action:@selector(xiaoxiClick:)];
     button2.titleLabel.font=[UIFont systemFontOfSize:12];
    [_headView addSubview:button1];
    [_headView addSubview:button2];
    self.navigationItem.titleView=_headView;

}

-(void)guanchangClick:(UIButton *)sender
{
}
-(void)xiaoxiClick:(UIButton *)sender
{
    OWTAppDelegate *delegate = (OWTAppDelegate*)[UIApplication sharedApplication].delegate;
    OQJNavCon *hx = delegate.hxChatNavCon;
    if (hx.viewControllers.count>0) {
        ChatListViewController *chatlistVC = [hx.viewControllers firstObject];
        [chatlistVC slimeRefreshStartRefresh:nil];
    }
//    [self.navigationController pushViewController:hx animated:NO];
    [self presentViewController:hx animated:NO completion:nil];
}
-(void)refreshTheTableView
{
    if (_tableView) {
        [_tableView headerBeginRefreshing];
    }

}
-(void)addAndUp
{
    [self createOrUpload];

}
-(void)showMenu
{
    if (!_sideMenu) {
        RESideMenuItem *message = [[RESideMenuItem alloc] initWithTitle:@"消息" image:[UIImage imageNamed:@"_0002_矢量智能对象"] highlightedImage:[UIImage imageNamed:@"_0002_矢量智能对象"] action:^(RESideMenu *menu, RESideMenuItem *item)  {
            [menu hide];
            
            OWTAppDelegate *delegate = (OWTAppDelegate*)[UIApplication sharedApplication].delegate;
            OQJNavCon *hx = delegate.hxChatNavCon;
            if (hx.viewControllers.count>0) {
                ChatListViewController *chatlistVC = [hx.viewControllers firstObject];
                [chatlistVC slimeRefreshStartRefresh:nil];
            }
            [self presentViewController:hx animated:YES completion:nil];
            
        }];
        RESideMenuItem *activityItem = [[RESideMenuItem alloc] initWithTitle:@"我的关注" image:[UIImage imageNamed:@"_0001_矢量智能对象"] highlightedImage:[UIImage imageNamed:@"_0001_矢量智能对象"] action:^(RESideMenu *menu, RESideMenuItem *item)  {
            [menu hide];
            [self showFollowings];
            
        }];
        RESideMenuItem *fans = [[RESideMenuItem alloc] initWithTitle:@"我的粉丝" image:[UIImage imageNamed:@"_0000_矢量智能对象"] highlightedImage:[UIImage imageNamed:@"_0000_矢量智能对象象"] action:^(RESideMenu *menu, RESideMenuItem *item){
            [menu hide];
            [self showFollowers];
            
            NSLog(@"Item %@", item);
        }];
        RESideMenuItem *invitePee = [[RESideMenuItem alloc] initWithTitle:@"邀请好友" image:[UIImage imageNamed:@"_0005_矢量智能对象"] highlightedImage:[UIImage imageNamed:@"_0005_矢量智能对象"] action:^(RESideMenu *menu, RESideMenuItem *item)  {
            [menu hide];
            [self presentSMSInvite];
            
            NSLog(@"Item %@", item);
        }];
        
        _sideMenu = [[RESideMenu alloc] initWithItems:@[message, activityItem, fans, invitePee]];
        _sideMenu.verticalOffset = IS_WIDESCREEN ? 250 : 76;
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapProfileImage:)];
        [_sideMenu.profileView addGestureRecognizer:tap];
        
        // _sideMenu.hideStatusBarArea = [self OSVersion] < 7;
    }
    
    [_sideMenu show];
}

-(void)onTapProfileImage:(UIGestureRecognizer *)sender
{
    [_sideMenu hide];
    OWTUser *userme =GetUserManager().currentUser;
    if (userme != nil)
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
        _userViewCon1.user =userme;
        
        
    }
    
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
                         [self takePhontos1];
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
-(void)takePhontos1{
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        [controller setSourceType:UIImagePickerControllerSourceTypeCamera];// 设置类型
        
        
        // 设置所支持的类型，设置只能拍照，或则只能录像，或者两者都可以
        NSString *requiredMediaType = ( NSString *)kUTTypeImage;
        NSString *requiredMediaType1 = ( NSString *)kUTTypeMovie;
        NSArray *arrMediaTypes=[NSArray arrayWithObjects:requiredMediaType, nil];
        [controller setMediaTypes:arrMediaTypes];
        
        // 设置录制视频的质量
//        [controller setVideoQuality:UIImagePickerControllerQualityTypeHigh];
        //设置最长摄像时间
//        [controller setVideoMaximumDuration:10.f];
    
        
//        [controller setAllowsEditing:YES];// 设置是否可以管理已经存在的图片或者视频
        [controller setDelegate:self];// 设置代理
        [self.navigationController presentViewController:controller animated:NO completion:^{
            
        }];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"Picker returned successfully.");
    NSLog(@"%@", info);
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    // 判断获取类型：图片
    if ([mediaType isEqualToString:( NSString *)kUTTypeImage]){
        UIImage *theImage = nil;
        // 判断，图片是否允许修改
        if ([picker allowsEditing]){
            //获取用户编辑之后的图像
            theImage = [info objectForKey:UIImagePickerControllerEditedImage];
        } else {
            // 照片的元数据参数
            theImage = [info objectForKey:UIImagePickerControllerOriginalImage];
            
        }
        NSMutableArray* imageInfos = [[NSMutableArray alloc] init];
        OWTImageInfo* imageInfo = [[OWTImageInfo alloc] init];
        imageInfo.image = theImage;
        [imageInfos addObject:imageInfo];
        OWTPhotoUploadViewController *photoUploadVC = [[OWTPhotoUploadViewController alloc] initWithNibName:nil bundle:nil];
        photoUploadVC.imageInfos = imageInfos;
        photoUploadVC.hidesBottomBarWhenPushed = YES;
        photoUploadVC.isCameraImages = YES;
        photoUploadVC.cancelAction=^{
            [self.navigationController popViewControllerAnimated:YES];
        };

        photoUploadVC.doneAction = ^{
            [self.navigationController popViewControllerAnimated:YES];
        };
        [self.navigationController pushViewController:photoUploadVC animated:NO];


    
    }
    
    [picker dismissViewControllerAnimated:nil completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:nil completion:nil];
}

-(void)takePhontos{
//    [_popoverViewCon dismissPopoverAnimated:NO];
    
    __weak __typeof(self) weakSelf = self;
    NBUImagePickerResultBlock resultBlock = ^(NSArray* images)
    {
        if (images == nil || images.count == 0)
        {
            return;
        }
        else
        {
            NSMutableArray* imageInfos = [[NSMutableArray alloc] init];
            OWTImageInfo* imageInfo = [[OWTImageInfo alloc] init];
            imageInfo.image = images[0];
            [imageInfos addObject:imageInfo];
            OWTPhotoUploadViewController *photoUploadVC = [[OWTPhotoUploadViewController alloc] initWithNibName:nil bundle:nil];
            photoUploadVC.imageInfos = imageInfos;
            photoUploadVC.hidesBottomBarWhenPushed = YES;
            photoUploadVC.isCameraImages = YES;
            photoUploadVC.doneAction = ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            };
            [weakSelf.navigationController pushViewController:photoUploadVC animated:NO];
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
    __weak __typeof(self) weakSelf = self;
    AGImagePickerController *imagePickerController = [[AGImagePickerController alloc] initWithFailureBlock:^(NSError *error) {
        
        if (error == nil)
        {
            NSLog(@"User has cancelled.");
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        } else
        {
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            });
        }
        

        
    } andSuccessBlock:^(NSArray *info) {
        NSLog(@"Info: %@", info);
        NSMutableArray* imageInfos = [NSMutableArray arrayWithCapacity:info.count];
        
        
        for (ALAsset* mediaInfo in info)
        {
            NSLog(@"Info: %@", mediaInfo);

            OWTImageInfo* imageInfo = [[OWTImageInfo alloc] init];
            
            imageInfo.url =[[mediaInfo valueForProperty:ALAssetPropertyAssetURL] absoluteString];

            imageInfo.primaryColorHex = @"DDDDDD";
            imageInfo.width = 64;
            imageInfo.height = 64;
            imageInfo.asset = mediaInfo;
            [imageInfos addObject:imageInfo];
        }
        
        [weakSelf dismissViewControllerAnimated:NO
                                     completion:^{
                                         OWTPhotoUploadViewController *photoUploadVC = [[OWTPhotoUploadViewController alloc] initWithNibName:nil bundle:nil];
                                         photoUploadVC.hidesBottomBarWhenPushed = YES;
                                         photoUploadVC.imageInfos = imageInfos;
                                         photoUploadVC.isCameraImages = NO;
                                         photoUploadVC.doneAction = ^{
                                             [weakSelf.navigationController popViewControllerAnimated:YES];
                                         };
                                         photoUploadVC.cancelAction=^{
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
    frame.size.height=frame.size.height-42-64;
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
    QJUser *user=[QJPassport sharedPassport].currentUser;
    QJInterfaceManager *fm=[QJInterfaceManager sharedManager];
    NSArray *arr=[_textField.text componentsSeparatedByString:@" "];
    BOOL ret=NO;
    for (NSString *str in arr) {
        if (![str isEqualToString:@""]) {
            ret=YES;
        }
    }
    if (_textField.text!=nil&&_textField.text.length!=0&&ret) {
        QJActionObject *actionModel=_activeList[_pageNum];
        NSMutableArray *comments=(NSMutableArray *)actionModel.comments;
        NSMutableArray *likes=(NSMutableArray *)actionModel.likes;
        QJCommentObject *commentModel=[[QJCommentObject alloc]init];
        commentModel.user=user;
        commentModel.comment=_textField.text;
        commentModel.time=[NSDate date];
        [comments addObject:commentModel];
        actionModel.comments=comments;
        [_activeList replaceObjectAtIndex:_pageNum withObject:actionModel];
        NSString *str;
        CGFloat imageHeight=(SCREENWIT-100)/9;
        CGFloat x=SCREENWIT-10-imageHeight;
        if (0) {
            str=[NSString stringWithFormat:@"%@%@%@   ",_replyid,_textField.text,user.uid];
        }else
        {
            str=[NSString stringWithFormat:@"%@%@ ",_textField.text,user.uid];
        }
        CGSize size=[str sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(x, 500)];
        NSString *h=_heights[_pageNum];
        NSString *he;
        float commentHeight=0;
        if (comments.count==1) {
            if (likes.count==0) {
                commentHeight+=10;
            }else {
                commentHeight+=20;
            }
        }
        commentHeight=size.height>imageHeight?size.height:imageHeight;
        if (comments.count==1) {
            he=[NSString stringWithFormat:@"%f",h.floatValue+commentHeight+10];
        }else {
            he=[NSString stringWithFormat:@"%f",h.floatValue+commentHeight+5];
        }
        [_heights replaceObjectAtIndex:_pageNum withObject:he];
        [self reloadData:_pageNum];
        
        if (0) {

        }
        else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error= [fm requestCommentAction:actionModel.aid comment:_textField.text];
                if (error==nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                    [self reloadData:_pageNum];
                    });

                }
            });
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

-(void)getTheCellHeight;
{
    _heights=(NSMutableArray *)[_cell getTheAllCellHeight:_activeList];
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

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  _activeList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *identifier=@"LJQuanjingCell";
    LJImageAndProfileCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[LJImageAndProfileCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier withViewController:self withComment:^(OWTActivityData *activity,NSInteger pageNum){
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
    
    cell.headerImagecb = ^(NSInteger page){
        QJActionObject *actionModel=_activeList[page];
            if(_userViewCon1){
                [_userViewCon1 adealloc];
                _userViewCon1 = nil;
            }
            _userViewCon1 = [[OWTUserViewCon alloc] initWithNibName:nil bundle:nil];
            _userViewCon1.hidesBottomBarWhenPushed = YES;
            _userViewCon1.ifFirstEnter = YES;
            _userViewCon1.rightTriggle = YES;
            _userViewCon1.quser=actionModel.user;
            __weak __typeof(&*self)weakSelf = self;
            [weakSelf.navigationController pushViewController:_userViewCon1 animated:YES];
        
    };
    
    cell.number=indexPath.row;
    [cell customcell:_activeList[indexPath.row] withImageNumber:_imageNum];
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
    QJInterfaceManager *fm=[QJInterfaceManager sharedManager];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [fm requestActionList:_cuIndex pageSize:30 userId:nil finished:^(NSArray * _Nonnull actionArray, NSArray * _Nonnull resultArray, NSNumber * _Nonnull nextCursorIndex, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView footerEndRefreshing];
                if (error) {
                    [SVProgressHUD showError:error];
                }else {
                    [_activeList addObjectsFromArray:actionArray];
                    [self getTheCellHeight];
                    _cuIndex=nextCursorIndex;
                    [_tableView reloadData];
                }
                
            });
        }];
    });

}


-(void)reloadData:(NSInteger)page
{
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:page inSection:0];
    NSArray *arr=[NSArray arrayWithObject:indexPath];
    [_tableView reloadRowsAtIndexPaths:arr withRowAnimation:NO];
}

- (void)refreshFeed
{
    QJInterfaceManager *fm=[QJInterfaceManager sharedManager];
    QJPassport *pt=[QJPassport sharedPassport];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [fm requestActionList:nil pageSize:30 userId:nil finished:^(NSArray * _Nonnull actionArray, NSArray * _Nonnull resultArray, NSNumber * _Nonnull nextCursorIndex, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView headerEndRefreshing];
                if (error) {
                    [SVProgressHUD showError:error];
                }else {
                    [_activeList removeAllObjects];
                    [_activeList addObjectsFromArray:actionArray];
                    [self getTheCellHeight];
                    _cuIndex=nextCursorIndex;
                    [_tableView reloadData];
                }

            });
        }];
    });
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
