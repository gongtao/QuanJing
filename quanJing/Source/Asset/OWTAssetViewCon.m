//
//  OWTAssetViewCon.m
//  Weitu
//
//  Created by Su on 4/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTAssetViewCon.h"
#import "OWTImageCell.h"
#import "OWTAssetInfoView.h"
//
#import "AlbumPhotosListView1.h"
#import "OWTAssetInfoViewa.h"
#import "OWTFont.h"
#import "OWTAsset.h"
#import "UIViewController+WTExt.h"
#import "OWTCommentsViewCon.h"
#import "OWTAuthManager.h"
#import "OWTServerError.h"
#import "OWTUserManager.h"
#import "OWTTabBarHider.h"
#import "OWTUserViewCon.h"

#import "OWTAssetEditViewCon.h"
#import "OWTAssetCollectViewCon.h"
#import "OWTAssetManager.h"
#import "SVProgressHUD+WTError.h"
#import "OWaterFlowCollectionView.h"
#import "UIView+EasyAutoLayout.h"
#import <QBFlatButton/QBFlatButton.h>
#import <SHBarButtonItemBlocks/SHBarButtonItemBlocks.h>
#import <SIAlertView/SIAlertView.h>
#import <SDWebImage/SDWebImageManager.h>
#import <ALAssetsLibrary-CustomPhotoAlbum/ALAssetsLibrary+CustomPhotoAlbum.h>
#import "XHImageViewer.h"
#import "OWTAssetManager.h"
#import "OWTServerError.h"
#import "FSBasicImage.h"
#import "FSBasicImageSource.h"
#import "LJAssetEditView.h"
#import "MJRefresh.h"
#import "UMSocial.h"
#import "NetStatusMonitor.h"
#import "LJAssetInfoView.h"
#import "ASIHTTPRequest.h"
#import "LJAssetLikeModel.h"
#import "OWTComment.h"
#import "OWTInputView.h"
static NSString* kWaterFlowCellID = @"kWaterFlowCellID";

@interface OWTAssetViewCon ()
{
    OWaterFlowLayout* _waterFlowLayout;
    UICollectionView* _collectionView;
    OWTTabBarHider* _tabBarHider;
    //
    NSMutableSet* _belongingAlbums;
    UIImageView *imageView1;
    ASIHTTPRequest *_asi;
    NSMutableArray *_likeBodys;
    UIImageView *_backView;
}

@property (nonatomic, strong) OWTAsset* asset;
@property (nonatomic, strong) OWTUser* assetOwnerUser;

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) OWTAssetInfoView* assetInfoView;
@property (nonatomic, strong) OWTAssetInfoViewa* assetInfoViewa;
@property (nonatomic, strong) NSLayoutConstraint* widthLayoutConstraint;

@property (nonatomic, strong) UIButton* likeButton;
@property (nonatomic, strong) UIButton* commentButton;

@property (nonatomic, assign) BOOL deletionAllowed;
@property (nonatomic, strong) void (^onDeleteAction)();


@property (nonatomic, assign) NSInteger jan;
@end

@implementation OWTAssetViewCon
{
    OWTInputView *_inputView;
    UIImageView *_imageView;
    UITextField *_textField;
    UIButton *_sendButton;
    NSMutableArray *_users;
}
- (instancetype)initWithAsset:(OWTAsset*)asset
{
    return [self initWithAsset:asset deletionAllowed:NO onDeleteAction:nil];
}

- (instancetype)initWithAsset:(OWTAsset*)asset
              deletionAllowed:(BOOL)deletionAllowed
               onDeleteAction:(void (^)())onDeleteAction
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _asset = asset;
        _deletionAllowed = deletionAllowed;
        _onDeleteAction = onDeleteAction;
        _likeBodys=[[NSMutableArray alloc]init];
        _users=[[NSMutableArray alloc]init];
        _isOpen=NO;
        [self setup];
    }
    return self;
}

- (void)setup
{
    _jan=2;
    _tabBarHider = [[OWTTabBarHider alloc] init];
    
    _waterFlowLayout = [[OWaterFlowLayout alloc] init];
    _waterFlowLayout.sectionInset = UIEdgeInsetsMake(5, 10, 5, 10);
    _waterFlowLayout.columnCount = 2;
    _collectionView = [[OWaterFlowCollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIT, SCREENHEI-64) collectionViewLayout:_waterFlowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = GetThemer().themeColorBackground;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.alwaysBounceVertical = YES;
//    [_collectionView addFooterWithTarget:self action:@selector(loadMore)];
//    _collectionView.footerPullToRefreshText=@"";
//    _collectionView.footerRefreshingText=@"";
//    _collectionView.footerReleaseToRefreshText=@"";
    //
    if (_asset != nil)
    {
        _assetOwnerUser = [GetUserManager() userForID:_asset.ownerUserID];
        
        if (_assetOwnerUser != nil)
        {
            OWTImageInfo* avatarImageInfo = _assetOwnerUser.avatarImageInfo;
            if (avatarImageInfo != nil)
            {
                
            }
            else
            {
            }
            
            NSRange aa=[_assetOwnerUser.nickname rangeOfString:@"全景"];
            if (aa.location != NSNotFound) {
                
                //
                _jan=1;
                
                
                
            }
            else
            {
                
            }
        }
        else
        {
            _jan=1;
        }
    }
    else
    {
    }
    //
            [_collectionView registerClass:[LJAssetInfoView class] forSupplementaryViewOfKind:kWaterFlowElementKindSectionHeader withReuseIdentifier:@"AssetInfoViewa"];
    
    [_collectionView registerClass:OWTImageCell.class forCellWithReuseIdentifier:kWaterFlowCellID];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_collectionView];
    //    [_collectionView easyFillSuperview];
    [self setupInputView];
    [self setupNavigationBar];
    
    [self reloadData];
}
-(void)setupInputView
{

    _imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, SCREENHEI-64-45, SCREENWIT, 45)];
    _imageView.userInteractionEnabled=YES;
    _imageView.backgroundColor=[UIColor whiteColor];
    _textField=[[UITextField alloc]initWithFrame:CGRectMake(10, 5, SCREENWIT-90, 34)];
    _textField.borderStyle=UITextBorderStyleRoundedRect;
    _textField.placeholder=@"发表评论";
    [_imageView addSubview:_textField];
    _sendButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_sendButton setBackgroundImage:[UIImage imageNamed:@"b3.png"] forState:UIControlStateNormal];
    [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_sendButton setFrame:CGRectMake(SCREENWIT-70, 5, 60, 34)];
    [_sendButton addTarget:self action:@selector(onSendBtn1:) forControlEvents:UIControlEventTouchUpInside];
    [_imageView addSubview:_sendButton];
    [self.view addSubview:_imageView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear2:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    _backView=[[UIImageView alloc]initWithFrame:CGRectZero];
    _backView.userInteractionEnabled=YES;
    [self.view addSubview:_backView];
    [self.view sendSubviewToBack:_backView];
    UITapGestureRecognizer *backTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backViewTap)];
    [_backView addGestureRecognizer:backTap];
}
#pragma mark backView Tap AND Click
-(void)backViewTap
{
    [_textField resignFirstResponder];
    _textField.text=nil;
}
-(void)onSendBtn1:(UIButton *)sender
{
    if (_textField.text.length>0) {
        [self postComment:_textField.text success:^{
            [_textField resignFirstResponder];
            _textField.text=nil;
            [SVProgressHUD dismiss];
        } failure:^{
            [SVProgressHUD dismiss];
        }];
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"请输入评论内容"];
    }
}
#pragma mark keyboardNotification
- (void)keyboardWillAppear2:(NSNotification *)notification
{
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
//    [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//
//    [self.view layoutIfNeeded];
//    [UIView commitAnimations];
    if ([_textField isFirstResponder]) {
    OWTAuthManager* am = GetAuthManager();
    if (!am.isAuthenticated)
    {
        SIAlertView* alertView = [[SIAlertView alloc] initWithTitle:@"请登录" andMessage:@"评论功能需要登录后使用"];
        [alertView addButtonWithTitle:@"登录"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView* alertView) {
                                  dispatch_async(dispatch_get_main_queue(),
                                                 ^{
                                                     [am showAuthViewConWithSuccess:^{
                                                         [self reloadData];
                                                     }
                                                                             cancel:^{
                                                                             }];
                                                 });
                                  [alertView dismissAnimated:YES];
                              }];
        
        [alertView addButtonWithTitle:@"取消"
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView* alertView) {
                                  [alertView dismissAnimated:YES];
                              }];
        
        alertView.transitionStyle = SIAlertViewTransitionStyleFade;
        [alertView show];
        [_textField resignFirstResponder];
    }
    else{
    CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animationTime animations:^{
        CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        _backView.frame=CGRectMake(0, 0, SCREENWIT, SCREENHEI-64-keyBoardFrame.size.height-45);
        [self.view bringSubviewToFront:_backView];
        _imageView.frame=CGRectMake(0, SCREENHEI-keyBoardFrame.size.height-45-64, SCREENWIT, 45);
    }];
    }}
    
}

- (void)keyboardWillDisappear:(NSNotification *)note
{
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
//    [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//
//    [self.view layoutIfNeeded];
//    [UIView commitAnimations];
    CGFloat animationTime = [[[note userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animationTime animations:^{
        CGRect keyBoardFrame = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        _backView.frame=CGRectMake(0, 0, SCREENWIT, SCREENHEI-64-keyBoardFrame.size.height);
        [self.view sendSubviewToBack:_backView];
        _imageView.frame=CGRectMake(0, SCREENHEI-45-64, SCREENWIT, 45);
    }];

}
- (void)setupNavigationBar
{
    self.navigationItem.title = @"图片";
    
//    _likeButton = [self createLikeButton];
    _commentButton = [self createCommentButton];
//    UIBarButtonItem* likeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_likeButton];
    UIBarButtonItem* commentButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_commentButton];
    
//    self.navigationItem.rightBarButtonItems = @[commentButtonItem];
}

- (void)dealloc
{
    _collectionView.delegate = nil; // XXX There might be some leak.
}

- (UIButton*)createLikeButton
{
    UIImage* buttonImage = [[OWTFont heartIconWithSize:24] imageWithSize:CGSizeMake(24, 24)];
    buttonImage = [buttonImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    QBFlatButton* button = [QBFlatButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button setTitle:@"喜欢" forState:UIControlStateNormal];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 2)];
    [button setTitleColor:GetThemer().themeColor forState:UIControlStateNormal];
    
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setSurfaceColor:[UIColor colorWithWhite:0.9 alpha:1.0] forState:UIControlStateNormal];
    [button setSurfaceColor:[UIColor colorWithWhite:0.8 alpha:1.0] forState:UIControlStateHighlighted];
    button.sideColor = [UIColor clearColor];
    button.bounds = CGRectMake(0, 0, 72, 28);
    button.cornerRadius = 4;
    button.depth = 0;
    button.height = 0;
    
    [button addTarget:self action:@selector(likeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (UIButton*)createCommentButton
{
    UIImage* buttonImage = [[OWTFont chatBoxIconWithSize:24] imageWithSize:CGSizeMake(24, 24)];
    buttonImage = [buttonImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    QBFlatButton* button = [QBFlatButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button setTitle:@"评论" forState:UIControlStateNormal];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 2)];
    [button setTitleColor:GetThemer().themeColor forState:UIControlStateNormal];
    
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setSurfaceColor:[UIColor colorWithWhite:0.9 alpha:1.0] forState:UIControlStateNormal];
    [button setSurfaceColor:[UIColor colorWithWhite:0.8 alpha:1.0] forState:UIControlStateHighlighted];
    button.sideColor = [UIColor clearColor];
    button.cornerRadius = 4;
    button.depth = 0;
    button.height = 0;
    
    button.bounds = CGRectMake(0, 0, 72, 28);
    button.imageView.tintColor = GetThemer().themeTintColor;
    
    [button addTarget:self action:@selector(commentButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getLikesBody];
    [self getCommentBody];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_collectionView reloadData];
    [self substituteNavigationBarBackItem];
    [self updateNavBarButtons];
    [self loadRelatedAssetsIfNecessary];
    [_tabBarHider hideTabBar];
    
}
- (void)updateNavBarButtons
{
    OWTUser* currentUser = GetUserManager().currentUser;
    if (currentUser != nil && [currentUser isOwnerOf:_asset])
    {
        static UIImage* kEditImage = nil;
        if (kEditImage == nil)
        {
            kEditImage = [[OWTFont editIconWithSize:26] imageWithSize:CGSizeMake(26, 26)];
            kEditImage = [kEditImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        
        UIButton* editButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
        [editButton setImage:kEditImage forState:UIControlStateNormal];
        [editButton setShowsTouchWhenHighlighted:TRUE];
        [editButton addTarget:self action:@selector(editAsset) forControlEvents:UIControlEventTouchDown];
        UIBarButtonItem* editItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
        
        UIBarButtonItem* backItem = self.navigationItem.leftBarButtonItem;
        if (backItem != nil)
        {
            self.navigationItem.leftBarButtonItems = @[backItem, editItem];
        }
        else
        {
            self.navigationItem.leftBarButtonItems = @[editItem];
        }
    }
    else
    {
        NSArray* items = self.navigationItem.leftBarButtonItems;
        items = [items subarrayWithRange:NSMakeRange(0, 1)];
        self.navigationItem.leftBarButtonItems = items;
    }
}

- (void)loadRelatedAssetsIfNecessary
{
    if (_asset.relatedAssets != nil)
    {
        return;
    }
    
    __weak typeof(self) wself = self;
    
    OWTAssetManager* am = GetAssetManager();
    [am queryRelatedAssetsForAsset:_asset
                           success:^{
                               [wself reloadData];
                           }
                           failure:^(NSError* error){
                               if (![NetStatusMonitor isExistenceNetwork]) {
                                   [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
                                   return ;
                               }
                               [SVProgressHUD showError:error];
                           }];
}

- (void)editAsset
{
    LJAssetEditView *ljvc=[[LJAssetEditView alloc]initWithAsset:self.asset deletionAllowed:_deletionAllowed];
    OWTAssetEditViewCon* editViewCon = [[OWTAssetEditViewCon alloc] initWithAsset:self.asset deletionAllowed:_deletionAllowed];
    ljvc.doneAction = ^(EWTDoneType doneType) {
        switch (doneType)
        {
            case nWTDoneTypeCancelled:
                [self dismissViewControllerAnimated:YES completion:nil];
                break;
            case nWTDoneTypeUpdated:
                [self reloadData];
                [self dismissViewControllerAnimated:YES completion:nil];
                break;
            case nWTDoneTypeDeleted:
            {
                AssertTR(_deletionAllowed);
                [self dismissViewControllerAnimated:YES completion:^{
                    if (_onDeleteAction != nil)
                    {
                        _onDeleteAction();
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                break;
            }
            default:
                break;
        }
    };
    editViewCon.doneAction=^(EWTDoneType doneType) {
        switch (doneType)
        {
            case nWTDoneTypeCancelled:
                [self dismissViewControllerAnimated:YES completion:nil];
                break;
            case nWTDoneTypeUpdated:
                [self reloadData];
                [self dismissViewControllerAnimated:YES completion:nil];
                break;
            case nWTDoneTypeDeleted:
            {
                AssertTR(_deletionAllowed);
                [self dismissViewControllerAnimated:YES completion:^{
                    if (_onDeleteAction != nil)
                    {
                        _onDeleteAction();
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                break;
            }
            default:
                break;
        }
    };

    UINavigationController* navCon = [[UINavigationController alloc] initWithRootViewController:editViewCon];
    UINavigationController *navc=[[UINavigationController alloc]initWithRootViewController:ljvc];
    [self presentViewController:navCon animated:YES completion:nil];
}

#pragma mark - Button Actions

- (void)likeButtonPressed
{
    OWTAuthManager* am = GetAuthManager();
    if (!am.isAuthenticated)
    {
        SIAlertView* alertView = [[SIAlertView alloc] initWithTitle:@"请登录" andMessage:@"喜欢功能需要登录后使用"];
        [alertView addButtonWithTitle:@"登录"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView* alertView) {
                                  dispatch_async(dispatch_get_main_queue(),
                                                 ^{
                                                     [am showAuthViewConWithSuccess:^{
                                                         [self reloadData];
                                                     }
                                                                             cancel:^{
                                                                             }];
                                                 });
                                  [alertView dismissAnimated:YES];
                              }];
        
        [alertView addButtonWithTitle:@"取消"
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView* alertView) {
                                  [alertView dismissAnimated:YES];
                              }];
        
        alertView.transitionStyle = SIAlertViewTransitionStyleFade;
        [alertView show];
    }
    else
    {
        if ([self isLiked:_likeBodys])
        {
            [self markLikedByMe:NO success:nil failure:nil];
        }
        else
        {
            [self markLikedByMe:YES success:nil failure:nil];
        }
    }
}
-(BOOL)isLiked:(NSArray *)likes
{
    for (LJAssetLikeModel *model in likes) {
        if ([model.userID isEqualToString:GetUserManager().currentUser.userID ]) {
            return YES;
        }
    }
    return NO;
}
- (void)commentButtonPressed
{
    OWTAuthManager* am = GetAuthManager();
    if (!am.isAuthenticated)
    {
        SIAlertView* alertView = [[SIAlertView alloc] initWithTitle:@"请登录" andMessage:@"评论相关功能需要登录后使用"];
        [alertView addButtonWithTitle:@"登录"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView* alertView) {
                                  dispatch_async(dispatch_get_main_queue(),
                                                 ^{
                                                     [am showAuthViewConWithSuccess:^{
                                                         OWTCommentsViewCon* commentsViewCon = [[OWTCommentsViewCon alloc] initWithNibName:nil bundle:nil];
                                                         commentsViewCon.asset = _asset;
                                                         UINavigationController* navCon = [[UINavigationController alloc] initWithRootViewController:commentsViewCon];
                                                         navCon.view.backgroundColor = [UIColor whiteColor];
                                                         [self presentViewController:navCon animated:YES completion:nil];
                                                     }
                                                                             cancel:^{
                                                                             }];
                                                 });
                                  [alertView dismissAnimated:YES];
                              }];
        
        [alertView addButtonWithTitle:@"取消"
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView* alertView) {
                                  [alertView dismissAnimated:YES];
                              }];
        
        alertView.transitionStyle = SIAlertViewTransitionStyleFade;
        [alertView show];
    }
    else
    {
        OWTCommentsViewCon* commentsViewCon = [[OWTCommentsViewCon alloc] initWithNibName:nil bundle:nil];
        commentsViewCon.asset = _asset;
        GetThemer().ifCommentPop = true;
        UINavigationController* navCon = [[UINavigationController alloc] initWithRootViewController:commentsViewCon];
        navCon.view.backgroundColor = [UIColor whiteColor];
        [self presentViewController:navCon animated:YES completion:nil];
    }
}

- (void)markLikedByMe:(BOOL)liked
              success:(void (^)())success
              failure:(void (^)())failure
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    NSString* action = liked ? @"like" : @"unlike";
    
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om postObject:nil
              path:[NSString stringWithFormat:@"assets1/%@/likes", _asset.assetID]
        parameters:@{ @"action" : action }
           success:^(RKObjectRequestOperation* o, RKMappingResult* result) {
               [o logResponse];
               
               NSDictionary* resultObjects = result.dictionary;
               OWTServerError* error = resultObjects[@"error"];
               if (error != nil)
               {
                   if (![NetStatusMonitor isExistenceNetwork]) {
                       [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
                   }else{
                       [SVProgressHUD showServerError:error];
                   }
                   if (failure != nil)
                   {
                       failure();
                   }
                   return;
               }
               
               OWTUser* currentUser = GetUserManager().currentUser;
               
               if (liked)
               {
                   [_asset markLikedByUser:currentUser.userID];
                   currentUser.assetsInfo.likedAssetNum = currentUser.assetsInfo.likedAssetNum + 1;
                   currentUser.assetsInfo.likedAssets = nil;
               }
               else
               {
                   [_asset markUnlikedByUser:currentUser.userID];
                   currentUser.assetsInfo.likedAssetNum = currentUser.assetsInfo.likedAssetNum - 1;
                   if (currentUser.assetsInfo.likedAssetNum < 0)
                   {
                       currentUser.assetsInfo.likedAssetNum = 0;
                   }
                   currentUser.assetsInfo.likedAssets = nil;
               }
               
               [self getLikesBody];
               
               [SVProgressHUD dismiss];
               
               if (success != nil)
               {
                   success();
               }
           }
           failure:^(RKObjectRequestOperation* o, NSError* error) {
               [o logResponse];
               if (![NetStatusMonitor isExistenceNetwork]) {
                   [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
               }else{
                   [SVProgressHUD showError:error];
               }
               
               if (failure != nil)
               {
                   failure();
               }
           }
     ];
}

#pragma mark - Data Reloading
-(void)getCommentBody
{
        if (_asset == nil)
        {
            return;
        }
        RKObjectManager* om = [RKObjectManager sharedManager];
        [om getObject:nil
                 path:[NSString stringWithFormat:@"assets1/%@/comments", _asset.assetID]
           parameters:nil
              success:^(RKObjectRequestOperation* o, RKMappingResult* result) {
                  [o logResponse];
                  
                  NSDictionary* resultObjects = result.dictionary;
                  OWTServerError* error = resultObjects[@"error"];
                  if (error != nil)
                  {
                      [SVProgressHUD showServerError:error];
                      return;
                  }
                  NSArray* commentDatas = resultObjects[@"comments"];
                  if (commentDatas == nil)
                  {
//                      [SVProgressHUD showGeneralError];
                      return;
                  }
                  OWTUserManager *um=GetUserManager();
                  for (OWTUserData *user in  resultObjects[@"users"]) {
                      [um registerUserData:user];
                  }
                  _asset.comments = [NSMutableArray arrayWithCapacity:commentDatas.count];
                  for (OWTCommentData* commentData in commentDatas)
                  {
                      OWTComment* comment = [OWTComment new];
                      [comment mergeWithData:commentData];
                      [_asset.comments addObject:comment];
                  }
                  [_collectionView reloadData];
                  [SVProgressHUD dismiss];
              }
              failure:^(RKObjectRequestOperation* o, NSError* error) {
                  [o logResponse];
                  if (![NetStatusMonitor isExistenceNetwork]) {
                      [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
                      return ;
                  }
                  [SVProgressHUD showError:error];
              }
         ];
}
-(void)getLikesBody
{
    
    NSString *urlStr=[NSString stringWithFormat:@"http://api.tiankong.com/qjapi/assets1/%@",_asset.assetID];
    _asi=[[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:urlStr]];
    _asi.delegate=self;
    [_asi startAsynchronous];
    
}
-(void)requestFailed:(ASIHTTPRequest *)request
{
    [SVProgressHUD showErrorWithStatus:@"网络不好"];
}
-(void)requestFinished:(ASIHTTPRequest *)request
{
    [_likeBodys removeAllObjects];
    NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:nil];
    for (NSDictionary *dict1 in dict[@"assteuser"][@"relatedUsers"]) {
        LJAssetLikeModel *model=[[LJAssetLikeModel alloc]init];
        model.smallURL=dict1[@"avatarImageInfo"][@"smallURL"];
        model.url=dict1[@"avatarImageInfo"][@"url"];
        model.nickname=dict1[@"nickname"];
        model.Signature=dict1[@"Signature"];
        model.userID=dict1[@"userID"];
        [_likeBodys addObject:model];
    }
    [_collectionView reloadData];

}
- (void)reloadData
{
    [self updateLikeButton];
    [_collectionView reloadData];
}

- (void)updateLikeButton
{
    if ([self isLiked:_likeBodys])
    {
//        [_likeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//        [_likeButton setTintColor:[UIColor redColor]];
        _isLike=YES;
    }
    else
    {
//        [_likeButton setTitleColor:GetThemer().themeColor forState:UIControlStateNormal];
//        [_likeButton setTintColor:GetThemer().themeTintColor];
        _isLike=NO;
    }
}

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0)
    {
        OWTAsset* relatedAsset = [self relatedAssetAtIndexPath:indexPath];
        if (relatedAsset != nil && relatedAsset.imageInfo != nil)
        {
            return relatedAsset.imageInfo.imageSize;
        }
        else
        {
            return CGSizeMake(1, 1);
        }
    }
    else
    {
        return CGSizeZero;
    }
}


#pragma mark - Collection View Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_asset == nil)
    {
        return 0;
    }
    
    if (_asset.relatedAssets == nil)
    {
        return 0;
    }
    
    return _asset.relatedAssets.count;
}

- (OWTAsset*)relatedAssetAtIndexPath:(NSIndexPath*)indexPath
{
    if (_asset == nil || _asset.relatedAssets == nil)
    {
        return nil;
    }
    
    NSInteger row = indexPath.row;
    if (row < _asset.relatedAssets.count)
    {
        return [_asset.relatedAssets objectAtIndex:row];
    }
    else
    {
        return nil;
    }
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OWTImageCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kWaterFlowCellID forIndexPath:indexPath];
    
    OWTAsset* asset = [self relatedAssetAtIndexPath:indexPath];
    if (asset != nil)
    {
        if (asset.imageInfo != nil)
        {
            //            [cell setImageWithInfo:asset.imageInfo];
            [cell.imageView setImageWithURL:[NSURL URLWithString:asset.imageInfo.smallURL]];
        }
        else
        {
            [cell setImageWithInfo:nil];
            cell.backgroundColor = [UIColor lightGrayColor];
        }
    }
    
    return cell;
}

// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == kWaterFlowElementKindSectionHeader)
    {
        
            LJAssetInfoView* assetInfoViewa = [collectionView dequeueReusableSupplementaryViewOfKind:kWaterFlowElementKindSectionHeader withReuseIdentifier:@"AssetInfoViewa" forIndexPath:indexPath];
            for (UIView *view in assetInfoViewa.subviews) {
                if (view.tag>=500) {
                    [view removeFromSuperview];
                }
            }
            [assetInfoViewa customViewWithAsset:_asset withLikes:_likeBodys withOpen:_isOpen withController:self];
            assetInfoViewa.canClick=YES;
            __weak OWTAssetViewCon* wself = self;
            assetInfoViewa.likeAction=^{[wself likeButtonPressed];};
            assetInfoViewa.reloadView=^{ [wself reloadData];  };
            assetInfoViewa.downloadAction = ^{ [wself downloadAsset]; };
            assetInfoViewa.collectAction = ^{ [wself collectAsset]; };
            assetInfoViewa.shareAction = ^{ [wself shareAsset]; };
            assetInfoViewa.showAllCommentsAction = ^{ [wself showAllAssetComments]; };
            assetInfoViewa.showOwnerUserAction = ^{ [wself showOwnerUser]; };
            assetInfoViewa.reportAction = ^{ [wself reportAsset]; };
            assetInfoViewa.showAction = ^{ [wself showAssetAction]; };
            return assetInfoViewa;
        }
    
    return nil;
}

- (void)downloadAsset
{
    [SVProgressHUD showWithStatus:@"保存图片中..." maskType:SVProgressHUDMaskTypeBlack];
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
    NSURL* url = [NSURL URLWithString:self.asset.imageInfo.url];
    [manager downloadWithURL:url
                     options:SDWebImageHighPriority
                    progress:nil
                   completed:^(UIImage* image, NSError* error, SDImageCacheType cacheType, BOOL finished){
                       if (image != nil)
                       {
                           ALAssetsLibrary* assetsLibrary = [[ALAssetsLibrary alloc] init];
                           [assetsLibrary saveImage:image
                                            toAlbum:@"全景"
                                         completion:^(NSURL* assetURL, NSError* error){
                                             [SVProgressHUD showSuccessWithStatus:@"保存成功"];
                                         }
                                            failure:^(NSError* error){
                                                [SVProgressHUD showSuccessWithStatus:@"保存成功"];
                                            }];
                       }
                       else
                       {
                           [SVProgressHUD showSuccessWithStatus:@"无法下载图片，请稍后再试。"];
                       }
                   }];
    
    
}

- (void)collectAsset
{
    OWTAuthManager* am = GetAuthManager();
    if (!am.isAuthenticated)
    {
        SIAlertView* alertView = [[SIAlertView alloc] initWithTitle:@"请登录" andMessage:@"收藏相关功能需要登录后使用"];
        [alertView addButtonWithTitle:@"登录"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView* alertView) {
                                  dispatch_async(dispatch_get_main_queue(),
                                                 ^{
                                                     [am showAuthViewConWithSuccess:^{
                                                         
                                                         OWTAssetManager* am = GetAssetManager();
                                                         
                                                         [SVProgressHUD show];
                                                         [am updateAsset:_asset
                                                         belongingAlbums:_belongingAlbums
                                                                 success:^{
                                                                     [SVProgressHUD showSuccessWithStatus:@"收藏成功"];
                                                                     [SVProgressHUD dismiss];
                                                                 }
                                                                 failure:^(NSError* error) {
                                                                     [SVProgressHUD showError:error];
                                                                 }];
                                                         
                                                         
                                                     }
                                                                             cancel:^{
                                                                             }];
                                                 });
                                  [alertView dismissAnimated:YES];
                              }];
        
        [alertView addButtonWithTitle:@"取消"
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView* alertView) {
                                  [alertView dismissAnimated:YES];
                              }];
        
        alertView.transitionStyle = SIAlertViewTransitionStyleFade;
        [alertView show];
    }
    else
    {
        //写收藏
        
        OWTAssetManager* am = GetAssetManager();
        
        [SVProgressHUD show];
        [am updateAsset:_asset
        belongingAlbums:_belongingAlbums
                success:^{
                    [SVProgressHUD showSuccessWithStatus:@"收藏成功"];
                    
                    [SVProgressHUD dismiss];
                    
                }
                failure:^(NSError* error) {
                    if (![NetStatusMonitor isExistenceNetwork]) {
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
                        return ;
                    }
                    [SVProgressHUD showError:error];
                }];
        
    }
}

- (void)shareAsset
{
    [SVProgressHUD showWithStatus:@"准备图片中..." maskType:SVProgressHUDMaskTypeBlack];
    
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
    NSURL* url = [NSURL URLWithString:self.asset.imageInfo.url];
    if (_isSquare!=YES) {
        
        [manager downloadWithURL:url
                         options:SDWebImageHighPriority
                        progress:nil
                       completed:^(UIImage* image, NSError* error, SDImageCacheType cacheType, BOOL finished){
                           if (image != nil)
                           {
                               NSString *urlStr = _asset.webURL;
                               [SVProgressHUD dismiss];
                               [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeNone;
                               [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
                               [UMSocialData defaultData].extConfig.wechatSessionData.url =  urlStr;
                               [UMSocialData defaultData].extConfig.wechatTimelineData.url =  urlStr;
                               [UMSocialData defaultData].extConfig.qqData.url =  urlStr;
                               [UMSocialData defaultData].extConfig.qzoneData.url =  urlStr;
                               [UMSocialData defaultData].extConfig.qqData.title = _asset.caption;
                               [UMSocialData defaultData].extConfig.qzoneData.title =_asset.caption;
                               [UMSocialData defaultData].extConfig.wechatSessionData.title =_asset.caption;
                               [UMSocialData defaultData].extConfig.wechatTimelineData.title =_asset.caption;
                               //                           [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:urlStr];
                               [UMSocialSnsService presentSnsIconSheetView:self
                                                                    appKey:nil
                                                                 shareText:nil
                                                                shareImage:image
                                                           shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSina,UMShareToWechatFavorite,UMShareToQzone,UMShareToQQ,UMShareToSms,nil]
                                                                  delegate:nil];
                               
                           }}];
    }
    else
    {
        [manager downloadWithURL:url
                         options:SDWebImageHighPriority
                        progress:nil
                       completed:^(UIImage* image, NSError* error, SDImageCacheType cacheType, BOOL finished){
                           [SVProgressHUD dismiss];
                           [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
                           [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
                           [UMSocialSnsService presentSnsIconSheetView:self
                                                                appKey:nil
                                                             shareText:nil
                                                            shareImage:image
                                                       shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatTimeline,UMShareToWechatSession,UMShareToWechatFavorite,UMShareToQzone,UMShareToQQ,UMShareToSms,nil]
                                                              delegate:nil];
                       }];
        
        
    }
    
}
- (void)showAllAssetComments
{
    [self commentButtonPressed];
}

- (void)showOwnerUser
{
    OWTUser* ownerUser = [GetUserManager() userForID:_asset.ownerUserID];
    //    NSLog(@"ddddddddddddddddd%@",_asset.ownerUserID);
    if (ownerUser != nil)
    {
        
        OWTUserViewCon* userViewCon1 = [[OWTUserViewCon alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:userViewCon1 animated:YES];
        userViewCon1.user =ownerUser;
        
    }
}

- (void)reportAsset
{
    OWTAssetManager* am = GetAssetManager();
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [am reportInappropriateAsset:_asset
                         success:^{
                             [SVProgressHUD showSuccessWithStatus:@"感谢您的举报，我们会尽快处理！"];
                         }
                         failure:^(NSError* error) {
                             [SVProgressHUD showErrorWithStatus:@"感谢您的举报，目前服务器有些问题，请稍后再试。"];
                         }];
}

#pragma mark - Collection view delegate

- (CGFloat)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout heightForHeaderInSection:(NSInteger)section
{
    NSArray *LikeBodys=_likeBodys;
    if (section == 0)
    {
            CGFloat viewHeight=0;
            float width=_asset.imageInfo.width;
            float height=_asset.imageInfo.height;
            float scr=SCREENWIT-20;
            viewHeight+=(10+scr/width*height);
            //四个按钮定制
            viewHeight+=(10+30);
            //标签 编号
        if (_asset.caption.length>0) {
            viewHeight+=50;}
        else {
            viewHeight+=30;
        }
        //喜欢的人
        CGFloat likeHeight=0;
        CGFloat imageHeight=20;
        if (LikeBodys.count!=0) {
            CGFloat likeWidth=45;
            CGFloat likeheight=0;
            for (NSInteger i=0;i<LikeBodys.count;i++) {
                LJAssetLikeModel *model=LikeBodys[i];
                if (likeWidth+imageHeight+5>SCREENWIT-25) {
                    likeWidth=45;
                    likeHeight+=(imageHeight+5);
                }
                likeWidth=likeWidth+imageHeight+10;
            }
            likeHeight+=imageHeight;
        }
        viewHeight+=likeHeight;
        NSArray *comment=_asset.comments;
        CGFloat commentHeight=0;
        if (comment.count!=0) {
            viewHeight+=10;
            if (likeHeight!=0) {
                viewHeight+=20;
                            }
            for (NSInteger i=0;i<comment.count;i++) {
                OWTComment *commentModel=comment[i];
                OWTUser* user = [GetUserManager() userForID:commentModel.userID];;
                NSString *name=user.nickname;
                NSString *commentContent=[NSString stringWithFormat:@"%@",commentModel.content];
                NSString *commentText=[NSString stringWithFormat:@"%@:%@",name,commentContent];
                NSMutableAttributedString *attString=[[NSMutableAttributedString alloc]initWithString:commentText];
                NSRange range1=[commentText rangeOfString:name];

                CGSize size2=[commentText sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(SCREENWIT-75-imageHeight, 500)];
                if (size2.height>imageHeight) {
                    commentHeight=commentHeight+size2.height+5;
                }else{
                    commentHeight=commentHeight+imageHeight+5;
                }
                
            }
        }else {
            if (likeHeight!=0) {
                viewHeight+=10;
            }
            
        }
        viewHeight+=commentHeight;
            return viewHeight;
        }
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (_jan==1) {
            OWTAssetInfoView* calculatingAssetInfoView = self.assetInfoView;
            calculatingAssetInfoView.asset = _asset;
            CGSize fittingSize = [calculatingAssetInfoView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
            CGFloat aspectRatio = fittingSize.height / fittingSize.width;
            fittingSize.width = self.view.bounds.size.width;
            fittingSize.height = ceil(fittingSize.width * aspectRatio);
            return fittingSize;
        }
        else
        {
//            OWTAssetInfoViewa* calculatingAssetInfoViewa = self.assetInfoViewa;
//            calculatingAssetInfoViewa.asset = _asset;
//            CGSize fittingSize = [calculatingAssetInfoViewa systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//            CGFloat aspectRatio = fittingSize.height / fittingSize.width;
//            fittingSize.width = self.view.bounds.size.width;
//            fittingSize.height = ceil(fittingSize.width * aspectRatio);
//            return fittingSize;
            return CGSizeMake(SCREENWIT, 800);
        }
        
    }
    
    return CGSizeZero;
}

- (OWTAssetInfoView*)assetInfoView
{
    if (_assetInfoView == nil)
    {
        UINib* headerNib = [UINib nibWithNibName:@"OWTAssetInfoView" bundle:nil];
        _assetInfoView = [[headerNib instantiateWithOwner:self options:nil] objectAtIndex:0];
        _widthLayoutConstraint = [NSLayoutConstraint constraintWithItem:_assetInfoView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:0
                                                               constant:self.view.bounds.size.width];
        [_assetInfoView addConstraint:_widthLayoutConstraint];
    }
    
    return _assetInfoView;
}

//
- (OWTAssetInfoViewa*)assetInfoViewa
{
    if (_assetInfoViewa == nil)
    {
        UINib* headerNib = [UINib nibWithNibName:@"OWTAssetInfoViewa" bundle:nil];
        _assetInfoViewa = [[headerNib instantiateWithOwner:self options:nil] objectAtIndex:0];
        _widthLayoutConstraint = [NSLayoutConstraint constraintWithItem:_assetInfoViewa
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:0
                                                               constant:self.view.bounds.size.width];
        [_assetInfoViewa addConstraint:_widthLayoutConstraint];
    }
    
    return _assetInfoViewa;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        OWTAsset* relatedAsset = [self relatedAssetAtIndexPath:indexPath];
        if (relatedAsset != nil)
        {
            OWTAssetViewCon* relatedAssetViewCon = [[OWTAssetViewCon alloc] initWithAsset:relatedAsset];
            [self.navigationController pushViewController:relatedAssetViewCon animated:YES];
        }
    }
}

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_tabBarHider notifyScrollViewWillBeginDraggin:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_tabBarHider notifyScrollViewDidScroll:scrollView];
}



//
//头像事件
-(void)showAssetAction
{
    //添加事件
    NSLog(@"1111111111111111111111111111111111111111111111");
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om getObject:nil
             path:[NSString stringWithFormat:@"assets/%@/related_assets", _asset.assetID]
       parameters:nil
          success:^(RKObjectRequestOperation* o, RKMappingResult* result) {
              [o logResponse];
              NSDictionary* resultObjects = result.dictionary;
              
              OWTServerError* error = resultObjects[@"error"];
              
              if (error != nil)
                  
              {
                  return;
              }
              NSArray* relatedAssetDatas = resultObjects[@"assets"];
              
              if (relatedAssetDatas == nil)
                  
              {
                  
                  
                  
                  return;
                  
              }
              
              NSMutableArray* relatedAssets = [GetAssetManager() registerAssetDatasAndReturnAssets:relatedAssetDatas];
              
              
              
              [_asset mergeWithRelatedAssets:relatedAssets];
              
              NSMutableArray *array = [[NSMutableArray alloc]init];
              [array addObject:_asset];
              
              for (id object in relatedAssetDatas) {
                  
                  OWTAsset *asset1 = object;
                  
                  [array addObject:asset1];
                  
              }
              NSMutableArray *FSArr = [[NSMutableArray alloc]init];
              
              NSMutableArray *imagesUrl = [[NSMutableArray alloc]init];
              
              for (int i=0; i<array.count; i++) {
                  
                  OWTAsset *asset1 = array[i];
                  
                  [imagesUrl addObject: asset1.imageInfo.url];
                  
                  
                  
                  FSBasicImage *firstPhoto = [[FSBasicImage alloc] initWithImageURL:[NSURL URLWithString:asset1.imageInfo.url] name:asset1.caption];
                  
                  [FSArr addObject:firstPhoto];
                  
                  
                  
              }
              FSBasicImageSource *photoSource = [[FSBasicImageSource alloc] initWithImages:FSArr];
              
              self.imageViewController = [[FSImageViewerViewController alloc] initWithImageSource:photoSource imageIndex:0 withViewController:self];
              
              //    [self.imageViewController moveToImageAtIndex:0 animated:NO];
              
              
              
              
              
              self.imageViewController.navigationController.navigationBarHidden =YES;
              
              if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                  
                  [self.navigationController presentViewController:_imageViewController animated:YES completion:nil];
                  
              }
              
              else {
                  
                  [self.navigationController pushViewController:_imageViewController animated:YES];
                  
              }
              
              
              
              
              
          }
     
          failure:^(RKObjectRequestOperation* o, NSError* error) {
              
              [o logResponse];
              
              
              
          }
     
     ];
    
    
}
- (void)postComment:(NSString*)content
            success:(void (^)())success
            failure:(void (^)())failure
{
    [SVProgressHUD showWithStatus:@"发送评论中..." maskType:SVProgressHUDMaskTypeClear];
    
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om postObject:nil
              path:[NSString stringWithFormat:@"assets1/%@/comments", _asset.assetID]
        parameters:@{ @"action" : @"addComment",
                      @"content" : content }
           success:^(RKObjectRequestOperation* o, RKMappingResult* result) {
               [o logResponse];
               
               NSDictionary* resultObjects = result.dictionary;
               OWTServerError* error = resultObjects[@"error"];
               if (error != nil)
               {
                   [SVProgressHUD showServerError:error];
                   
                   if (failure != nil)
                   {
                       failure();
                   }
                   
                   return;
               }
               
               OWTCommentData* commentData = resultObjects[@"comment"];
               if (commentData == nil)
               {
                   [SVProgressHUD showGeneralError];
                   
                   if (failure != nil)
                   {
                       failure();
                   }
                   
                   return;
               }
               
               OWTComment* comment = [OWTComment new];
               [comment mergeWithData:commentData];
               
               [_asset addComment:comment];
               
               [_collectionView reloadData];
               if (success!=nil) {
                   success();
               }
           }
           failure:^(RKObjectRequestOperation* o, NSError* error) {
               [o logResponse];
               if (![NetStatusMonitor isExistenceNetwork]) {
                   [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
               }else{
                   [SVProgressHUD showError:error];
               }
               
               if (failure != nil)
               {
                   failure();
               }
           }
     ];
}

-(void)loadMore
{
    
    
}
@end
