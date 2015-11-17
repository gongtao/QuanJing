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
#import <UIImageView+WebCache.h>
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
#import "QuanJingSDK.h"
#import "MobClick.h"
static NSString * kWaterFlowCellID = @"kWaterFlowCellID";

@interface OWTAssetViewCon () <NSCopying>
{
	OWaterFlowLayout * _waterFlowLayout;
	UICollectionView * _collectionView;
	OWTTabBarHider * _tabBarHider;
	//
	NSMutableSet * _belongingAlbums;
	UIImageView * imageView1;
	ASIHTTPRequest * _asi;
	NSMutableArray * _likeBodys;
	UIImageView * _backView;
	BOOL _isLikeTap;
	NSInteger _adaptWith;
}

@property (nonatomic, strong) QJImageObject * imageAsset;
@property (nonatomic, strong) OWTUser * assetOwnerUser;

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) OWTAssetInfoView * assetInfoView;
@property (nonatomic, strong) OWTAssetInfoViewa * assetInfoViewa;
@property (nonatomic, strong) NSLayoutConstraint * widthLayoutConstraint;

@property (nonatomic, strong) UIButton * likeButton;
@property (nonatomic, strong) UIButton * commentButton;

@property (nonatomic, assign) BOOL deletionAllowed;
@property (nonatomic, strong) void (^onDeleteAction)();

@property (nonatomic, assign) NSInteger jan;
@property(nonatomic, strong) NSNumber * imageId;
@property(nonatomic, strong) NSNumber * imageType;
@property (nonatomic, strong) NSMutableOrderedSet * searchResults;
@end

@implementation OWTAssetViewCon
{
	OWTInputView * _inputView;
	UIImageView * _imageView;
	UITextField * _textField;
	UIButton * _sendButton;
	NSMutableArray * _users;
}
- (instancetype)initWithAsset:(QJImageObject *)asset
{
	return [self initWithAsset:asset deletionAllowed:NO onDeleteAction:nil];
}

- (instancetype)initWithAsset:(QJImageObject *)asset initWithType:(NSInteger)type
{
	self.imageType = [[NSNumber alloc]initWithInteger:type];
	return [self initWithAsset:asset deletionAllowed:NO onDeleteAction:nil];
}

// 新的接口
- (instancetype)initWithImageId:(QJImageObject *)imageAsset imageType:(NSNumber *)imageType
{
	self = [super initWithNibName:nil bundle:nil];
	
	if (self) {
		_imageAsset = imageAsset;
		_imageType = imageType;
		_isOpen = NO;
		[self setup];
	}
	return self;
}

- (instancetype)initWithAsset:(QJImageObject *)asset
	deletionAllowed:(BOOL)deletionAllowed
	onDeleteAction:(void (^)())onDeleteAction
{
	self = [super initWithNibName:nil bundle:nil];
	
	if (self) {
		_imageAsset = asset;
		_imageType = asset.imageType;
		_deletionAllowed = deletionAllowed;
		_onDeleteAction = onDeleteAction;
		_isOpen = NO;
		[self setup];
	}
	return self;
}

- (void)setup
{
	_jan = 2;
	_tabBarHider = [[OWTTabBarHider alloc] init];
	
	_waterFlowLayout = [[OWaterFlowLayout alloc] init];
	_waterFlowLayout.sectionInset = UIEdgeInsetsMake(5, 10, 5, 10);
	_waterFlowLayout.columnCount = 2;
	_collectionView = [[OWaterFlowCollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIT, SCREENHEI - 64 - 45) collectionViewLayout:_waterFlowLayout];
	_adaptWith = SCREENWIT / 2 - 40;
	_collectionView.delegate = self;
	_collectionView.dataSource = self;
	_collectionView.backgroundColor = GetThemer().themeColorBackground;
	_collectionView.showsHorizontalScrollIndicator = NO;
	_collectionView.showsVerticalScrollIndicator = NO;
	_collectionView.alwaysBounceVertical = YES;
	
	if (_imageAsset != nil) {
		if (_assetOwnerUser != nil) {
			NSRange aa = [_assetOwnerUser.nickname rangeOfString:@"全景"];
			
			if (aa.location != NSNotFound) {
				//
				_jan = 1;
			}
			else {}
		}
		else {
			_jan = 1;
		}
	}
	
	[_collectionView registerClass:[LJAssetInfoView class] forSupplementaryViewOfKind:kWaterFlowElementKindSectionHeader withReuseIdentifier:@"AssetInfoViewa"];
	
	[_collectionView registerClass:OWTImageCell.class forCellWithReuseIdentifier:kWaterFlowCellID];
	_collectionView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:_collectionView];
	
	[self setupInputView];
	[self setupNavigationBar];
	[self getLikeAndCommendData];
}

- (void)getLikeAndCommendData
{
	NSInteger integer = ([_imageAsset.imageType integerValue] == 1) ? 1 : 2;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[[QJInterfaceManager sharedManager] requestImageDetail:_imageAsset.imageId imageType:[NSNumber numberWithInteger:integer] finished:^(QJImageObject * imageObject, NSError * error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (error) {
					[SVProgressHUD showErrorWithStatus:@"网络连接错误"];
					return;
				}
				
				if (imageObject != nil) {
					_imageAsset.tag = imageObject.tag;
					_imageAsset.captionCn = imageObject.captionCn;
					_imageAsset.comments = [[imageObject.comments reverseObjectEnumerator] allObjects];
					_imageAsset.likes = imageObject.likes;
					_imageAsset.userId = imageObject.userId;
					_imageAsset.descript = imageObject.descript;
					[self reloadData];
					[self loadRelatedAssetsInSearch];
				}
				else {
					[SVProgressHUD showErrorWithStatus:@"没有找到图片"];
				}
			});
		}];
	});
}

- (void)setupInputView
{
	_imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, SCREENHEI - 64 - 45, SCREENWIT, 45)];
	_imageView.userInteractionEnabled = YES;
	_imageView.backgroundColor = [UIColor whiteColor];
	_textField = [[UITextField alloc]initWithFrame:CGRectMake(10, 5, SCREENWIT - 90, 34)];
	_textField.borderStyle = UITextBorderStyleRoundedRect;
	_textField.placeholder = @"发表评论";
	[_imageView addSubview:_textField];
	_sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_sendButton setBackgroundImage:[UIImage imageNamed:@"b3.png"] forState:UIControlStateNormal];
	[_sendButton setTitle:@"发送" forState:UIControlStateNormal];
	[_sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[_sendButton setFrame:CGRectMake(SCREENWIT - 70, 5, 60, 34)];
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
	_backView = [[UIImageView alloc]initWithFrame:CGRectZero];
	_backView.userInteractionEnabled = YES;
	[self.view addSubview:_backView];
	[self.view sendSubviewToBack:_backView];
	UITapGestureRecognizer * backTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backViewTap)];
	[_backView addGestureRecognizer:backTap];
}

#pragma mark backView Tap AND Click
- (void)backViewTap
{
	[_textField resignFirstResponder];
	_textField.text = nil;
}

- (void)onSendBtn1:(UIButton *)sender
{
	if (_textField.text.length > 0) {
		[SVProgressHUD showWithStatus:@"发送评论中..." maskType:SVProgressHUDMaskTypeClear];
		[self postComment];
	}
	else {
		[SVProgressHUD showErrorWithStatus:@"请输入评论内容"];
	}
}

- (void)postComment
{
	QJInterfaceManager * fm = [QJInterfaceManager sharedManager];
	NSNumber * typeNumber = ([_imageAsset.imageType integerValue] == 1) ?[NSNumber numberWithInt:1] :[NSNumber numberWithInt:2];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSError * error = [fm requestImageComment:_imageAsset.imageId imageType:typeNumber comment:_textField.text];
		dispatch_async(dispatch_get_main_queue(), ^{
			if (error != nil) {
				if (![NetStatusMonitor isExistenceNetwork])
					[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
				else
					[SVProgressHUD showError:error];
				return;
			}
			[SVProgressHUD dismiss];
			QJCommentObject * commentModel = [[QJCommentObject alloc]init];
			commentModel.comment = _textField.text;
			commentModel.user = [QJPassport sharedPassport].currentUser;
			commentModel.time = [self getDate];
			NSMutableArray * comment;
			
			if (_imageAsset.comments)
				comment = (NSMutableArray *)_imageAsset.comments;
			else
				comment = [[NSMutableArray alloc]init];
			[comment insertObject:commentModel atIndex:0];
			_imageAsset.comments = comment;
			[_collectionView reloadData];
			[self backViewTap];
		});
	});
}

- (NSDate *)getDate
{
	NSDate * date = [NSDate date];
	NSTimeZone * zone = [NSTimeZone systemTimeZone];
	NSInteger interval = [zone secondsFromGMTForDate:date];
	NSDate * localeDate = [date  dateByAddingTimeInterval:interval];
	
	return localeDate;
}

#pragma mark keyboardNotification
- (void)keyboardWillAppear2:(NSNotification *)notification
{
	if ([_textField isFirstResponder]) {
		OWTAuthManager * am = GetAuthManager();
		
		if (!am.isAuthenticated) {
			SIAlertView * alertView = [[SIAlertView alloc] initWithTitle:@"请登录" andMessage:@"评论功能需要登录后使用"];
			[alertView addButtonWithTitle:@"登录"
			type:SIAlertViewButtonTypeDefault
			handler:^(SIAlertView * alertView) {
				dispatch_async(dispatch_get_main_queue(),
				^{
					[am showAuthViewConWithSuccess:^{
						[self reloadData];
					}
					cancel:^{}];
				});
				[alertView dismissAnimated:YES];
			}];
			
			[alertView addButtonWithTitle:@"取消"
			type:SIAlertViewButtonTypeCancel
			handler:^(SIAlertView * alertView) {
				[alertView dismissAnimated:YES];
			}];
			
			alertView.transitionStyle = SIAlertViewTransitionStyleFade;
			[alertView show];
			[_textField resignFirstResponder];
		}
		else {
			CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
			[UIView animateWithDuration:animationTime animations:^{
				CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
				_backView.frame = CGRectMake(0, 0, SCREENWIT, SCREENHEI - 64 - keyBoardFrame.size.height - 45);
				[self.view bringSubviewToFront:_backView];
				_imageView.frame = CGRectMake(0, SCREENHEI - keyBoardFrame.size.height - 45 - 64, SCREENWIT, 45);
			}];
		}
	}
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
		_backView.frame = CGRectMake(0, 0, SCREENWIT, SCREENHEI - 64 - keyBoardFrame.size.height);
		[self.view sendSubviewToBack:_backView];
		_imageView.frame = CGRectMake(0, SCREENHEI - 45 - 64, SCREENWIT, 45);
	}];
}

- (void)setupNavigationBar
{
	self.navigationItem.title = @"图片";
	
	//    _likeButton = [self createLikeButton];
	_commentButton = [self createCommentButton];
	//    UIBarButtonItem* likeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_likeButton];
	//	UIBarButtonItem * commentButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_commentButton];
	
	//    self.navigationItem.rightBarButtonItems = @[commentButtonItem];
}

- (void)dealloc
{
	_collectionView.delegate = nil;	// XXX There might be some leak.
}

- (UIButton *)createLikeButton
{
	UIImage * buttonImage = [[OWTFont heartIconWithSize:24] imageWithSize:CGSizeMake(24, 24)];
	
	buttonImage = [buttonImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	
	QBFlatButton * button = [QBFlatButton buttonWithType:UIButtonTypeCustom];
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

- (UIButton *)createCommentButton
{
	UIImage * buttonImage = [[OWTFont chatBoxIconWithSize:24] imageWithSize:CGSizeMake(24, 24)];
	
	buttonImage = [buttonImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	
	QBFlatButton * button = [QBFlatButton buttonWithType:UIButtonTypeCustom];
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
	_searchResults = [[NSMutableOrderedSet alloc]init];
	
	// [self getAllAssetData];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[_collectionView reloadData];
	[self substituteNavigationBarBackItem];
	//    [self updateNavBarButtons];
	[_tabBarHider hideTabBar];
	[MobClick beginEvent:@"图片详情"];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[MobClick endEvent:@"图片详情"];
}

- (void)updateNavBarButtons
{
	QJUser * user = [QJPassport sharedPassport].currentUser;
	
	if ([user.uid.stringValue isEqualToString:_imageAsset.userId.stringValue]) {
		static UIImage * kEditImage = nil;
		
		if (kEditImage == nil) {
			kEditImage = [[OWTFont editIconWithSize:26] imageWithSize:CGSizeMake(26, 26)];
			kEditImage = [kEditImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		}
		
		UIButton * editButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
		[editButton setImage:kEditImage forState:UIControlStateNormal];
		[editButton setShowsTouchWhenHighlighted:TRUE];
		[editButton addTarget:self action:@selector(editAsset) forControlEvents:UIControlEventTouchDown];
		UIBarButtonItem * editItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
		
		UIBarButtonItem * backItem = self.navigationItem.leftBarButtonItem;
		
		if (backItem != nil)
			self.navigationItem.leftBarButtonItems = @[backItem, editItem];
		else
			self.navigationItem.leftBarButtonItems = @[editItem];
	}
	else {
		NSArray * items = self.navigationItem.leftBarButtonItems;
		items = [items subarrayWithRange:NSMakeRange(0, 1)];
		self.navigationItem.leftBarButtonItems = items;
	}
}

// - (void)editAsset
// {
//    LJAssetEditView *ljvc=[[LJAssetEditView alloc]initWithAsset:self.asset deletionAllowed:_deletionAllowed];
//    OWTAssetEditViewCon* editViewCon = [[OWTAssetEditViewCon alloc] initWithAsset:self.asset deletionAllowed:_deletionAllowed];
//    ljvc.doneAction = ^(EWTDoneType doneType) {
//        switch (doneType)
//        {
//            case nWTDoneTypeCancelled:
//                [self dismissViewControllerAnimated:YES completion:nil];
//                break;
//            case nWTDoneTypeUpdated:
//                [self reloadData];
//                [self dismissViewControllerAnimated:YES completion:nil];
//                break;
//            case nWTDoneTypeDeleted:
//            {
//                AssertTR(_deletionAllowed);
//                [self dismissViewControllerAnimated:YES completion:^{
//                    if (_onDeleteAction != nil)
//                    {
//                        _onDeleteAction();
//                    }
//                    [self.navigationController popViewControllerAnimated:YES];
//                }];
//                break;
//            }
//            default:
//                break;
//        }
//    };
//    editViewCon.doneAction=^(EWTDoneType doneType) {
//        switch (doneType)
//        {
//            case nWTDoneTypeCancelled:
//                [self dismissViewControllerAnimated:YES completion:nil];
//                break;
//            case nWTDoneTypeUpdated:
//                [self reloadData];
//                [self dismissViewControllerAnimated:YES completion:nil];
//                break;
//            case nWTDoneTypeDeleted:
//            {
//                AssertTR(_deletionAllowed);
//                [self dismissViewControllerAnimated:YES completion:^{
//                    if (_onDeleteAction != nil)
//                    {
//                        _onDeleteAction();
//                    }
//                    [self.navigationController popViewControllerAnimated:YES];
//                }];
//                break;
//            }
//            default:
//                break;
//        }
//    };
//
//    UINavigationController* navCon = [[UINavigationController alloc] initWithRootViewController:editViewCon];
//    UINavigationController *navc=[[UINavigationController alloc]initWithRootViewController:ljvc];
//    [self presentViewController:navCon animated:YES completion:nil];
// }
//

- (void)mergeAssets:(NSArray *)imageObjectArray
{
	[_searchResults addObjectsFromArray:imageObjectArray];
	[self reloadData];
}

#pragma mark -getImages
- (void)loadImageAssets
{
	QJInterfaceManager * fm = [QJInterfaceManager sharedManager];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[fm requestUserImageList:_imageAsset.userId pageNum:_searchResults.count / 50 + 1 pageSize:50 currentImageId:_imageAsset.imageId finished:^(NSArray * _Nonnull imageObjectArray, BOOL isLastPage, NSArray * _Nonnull resultArray, NSError * _Nonnull error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (error) {
					[SVProgressHUD showErrorWithStatus:@"网络连接错误"];
					return;
				}
				
				if (imageObjectArray.count == 0) {
					[SVProgressHUD showErrorWithStatus:@"没有找到图片"];
				}
				else {
					[self mergeAssets:imageObjectArray];
					[SVProgressHUD dismiss];
				}
			});
		}];
	});
}

- (void)loadRelatedAssetsInSearch
{
	QJInterfaceManager * fm = [QJInterfaceManager sharedManager];
	
	if (_imageType.intValue == 1) {
		NSString * searchTag = _imageAsset.tag;
		
		if (!searchTag || (searchTag.length == 0))
			searchTag = _imageAsset.descript;
			
		if (!searchTag || (searchTag.length == 0))
			return;
			
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[fm requestImageSearchKey:searchTag
			pageNum:_searchResults.count / 50 + 1 pageSize:50
			currentImageId:_imageAsset.imageId
			finished:^(NSArray * _Nonnull imageObjectArray, NSArray * _Nonnull resultArray, NSError * _Nonnull error) {
				dispatch_async(dispatch_get_main_queue(), ^{
					if (error) {
						[SVProgressHUD showErrorWithStatus:@"网络连接错误"];
						return;
					}
					
					if (imageObjectArray.count == 0) {
						[SVProgressHUD showErrorWithStatus:@"没有找到图片"];
						return;
					}
					[self mergeAssets:imageObjectArray];
					[SVProgressHUD dismiss];
				});
			}];
		});
		// 操作当前用户资源
	}
	else if ([_imageType integerValue] == 2) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[fm requestUserImageList:_imageAsset.userId
			pageNum:1
			pageSize:50
			currentImageId:_imageAsset.imageId
			finished:^(NSArray * albumObjectArray, BOOL isLastPage, NSArray * resultArray, NSError * error) {
				dispatch_async(dispatch_get_main_queue(), ^{
					if (error == nil) {
						if (albumObjectArray != nil) {
							[self mergeAssets:albumObjectArray];
							[SVProgressHUD dismiss];
						}
					}
					else {
						[SVProgressHUD showErrorWithStatus:@"请求失败"];
					}
				});
			}];
		});
	}
	else {
		// 操作当前用户资源d
		[self loadImageAssets];
	}
}

#pragma mark - Button Actions 点击赞过的人
- (void)likeButtonPressed
{
	OWTAuthManager * am = GetAuthManager();
	
	if (!am.isAuthenticated) {
		SIAlertView * alertView = [[SIAlertView alloc] initWithTitle:@"请登录" andMessage:@"喜欢功能需要登录后使用"];
		[alertView addButtonWithTitle:@"登录"
		type:SIAlertViewButtonTypeDefault
		handler:^(SIAlertView * alertView) {
			dispatch_async(dispatch_get_main_queue(),
			^{
				[am showAuthViewConWithSuccess:^{
					[self reloadData];
				}
				cancel:^{}];
			});
			[alertView dismissAnimated:YES];
		}];
		
		[alertView addButtonWithTitle:@"取消"
		type:SIAlertViewButtonTypeCancel
		handler:^(SIAlertView * alertView) {
			[alertView dismissAnimated:YES];
		}];
		
		alertView.transitionStyle = SIAlertViewTransitionStyleFade;
		[alertView show];
	}
	else {
		if ([self isLike:_imageAsset.likes])
			[self markLikedByMe:NO success:nil failure:nil];
		else
			[self markLikedByMe:YES success:nil failure:nil];
	}
}

#pragma -mark 判断对改图片是否已点过赞
- (BOOL)isLike:(NSArray *)like
{
	for (QJUser * ljlike in like)
		if ([[QJPassport sharedPassport].currentUser.uid.stringValue isEqualToString:ljlike.uid.stringValue])
			return YES;
			
	return NO;
}

- (void)commentButtonPressed
{
	OWTAuthManager * am = GetAuthManager();
	
	if (!am.isAuthenticated) {
		SIAlertView * alertView = [[SIAlertView alloc] initWithTitle:@"请登录" andMessage:@"评论相关功能需要登录后使用"];
		[alertView addButtonWithTitle:@"登录"
		type:SIAlertViewButtonTypeDefault
		handler:^(SIAlertView * alertView) {
			dispatch_async(dispatch_get_main_queue(),
			^{
				[am showAuthViewConWithSuccess:^{
					OWTCommentsViewCon * commentsViewCon = [[OWTCommentsViewCon alloc] initWithNibName:nil bundle:nil];
					commentsViewCon.asset = _imageAsset;
					UINavigationController * navCon = [[UINavigationController alloc] initWithRootViewController:commentsViewCon];
					navCon.view.backgroundColor = [UIColor whiteColor];
					[self presentViewController:navCon animated:YES completion:nil];
				}
				cancel:^{}];
			});
			[alertView dismissAnimated:YES];
		}];
		
		[alertView addButtonWithTitle:@"取消"
		type:SIAlertViewButtonTypeCancel
		handler:^(SIAlertView * alertView) {
			[alertView dismissAnimated:YES];
		}];
		
		alertView.transitionStyle = SIAlertViewTransitionStyleFade;
		[alertView show];
	}
	else {
		OWTCommentsViewCon * commentsViewCon = [[OWTCommentsViewCon alloc] initWithNibName:nil bundle:nil];
		commentsViewCon.asset = _imageAsset;
		GetThemer().ifCommentPop = true;
		UINavigationController * navCon = [[UINavigationController alloc] initWithRootViewController:commentsViewCon];
		navCon.view.backgroundColor = [UIColor whiteColor];
		[self presentViewController:navCon animated:YES completion:nil];
	}
}

- (void)markLikedByMe:(BOOL)liked
	success:(void (^)())success
	failure:(void (^)())failure
{
	[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
	
	if (liked) {
		QJInterfaceManager * fm = [QJInterfaceManager sharedManager];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSError * error = [fm requestImageLike:_imageAsset.imageId imageType:_imageType];
			dispatch_async(dispatch_get_main_queue(), ^{
				if (error != nil) {
					if (![NetStatusMonitor isExistenceNetwork])
						[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
					else
						[SVProgressHUD showError:error];
					return;
				}
				_isLikeTap = YES;
				NSMutableArray * likesArr = (NSMutableArray *)_imageAsset.likes;
				
				if (likesArr == nil)
					likesArr = [[NSMutableArray alloc]init];
				[likesArr addObject:[QJPassport sharedPassport].currentUser];
				_imageAsset.likes = likesArr;
				[_collectionView reloadData];
				[SVProgressHUD showSuccessWithStatus:@"喜欢成功"];
			});
		});
	}
	else {
		QJInterfaceManager * fm = [QJInterfaceManager sharedManager];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSError * error = [fm requestImageCancelLike:_imageAsset.imageId imageType:_imageType];
			dispatch_async(dispatch_get_main_queue(), ^{
				if (error != nil) {
					if (![NetStatusMonitor isExistenceNetwork])
						[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
					else
						[SVProgressHUD showError:error];
					return;
				}
				_isLikeTap = YES;
				NSMutableArray * likesArr = (NSMutableArray *)_imageAsset.likes;
				int i = 0;
				
				for (QJUser * user in likesArr) {
					if ([user.uid.stringValue isEqualToString:[QJPassport sharedPassport].currentUser.uid.stringValue])
						break;
					i++;
				}
				
				[likesArr removeObjectAtIndex:i];
				_imageAsset.likes = likesArr;
				[_collectionView reloadData];
				[SVProgressHUD showSuccessWithStatus:@"取消喜欢成功"];
			});
		});
	}
}

#pragma mark - Data Reloading
- (void)getAllAssetData
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[[QJInterfaceManager sharedManager]requestImageDetail:_imageAsset.imageId imageType:_imageType finished:^(QJImageObject * _Nonnull imageObject, NSError * _Nonnull error) {
			if (error == nil) {
				_imageAsset = imageObject;
				dispatch_async(dispatch_get_main_queue(), ^{
					[_collectionView reloadData];
				});
			}
		}];
	});
}

- (void)reloadData
{
	[self updateLikeButton];
	[_collectionView reloadData];
}

- (void)updateLikeButton
{
	if ([self isLike:_likeBodys])
		//        [_likeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
		//        [_likeButton setTintColor:[UIColor redColor]];
		_isLike = YES;
	else
		//        [_likeButton setTitleColor:GetThemer().themeColor forState:UIControlStateNormal];
		//        [_likeButton setTintColor:GetThemer().themeTintColor];
		_isLike = NO;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
		QJImageObject * relatedAsset = [self relatedAssetAtIndexPath:indexPath];
		
		if ((relatedAsset != nil) && (relatedAsset.width != nil) && (relatedAsset.height != nil))
			return CGSizeMake([relatedAsset.width floatValue], [relatedAsset.height floatValue]);
		else
			return CGSizeMake(1, 1);
	}
	else {
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
	if (_imageAsset == nil)
		return 0;
		
	if (_searchResults == nil)
		return 0;
		
	return _searchResults.count;
}

- (QJImageObject *)relatedAssetAtIndexPath:(NSIndexPath *)indexPath
{
	if ((_imageAsset == nil) || (_searchResults == nil))
		return nil;
		
	NSInteger row = indexPath.row;
	
	if (row < _searchResults.count)
		return [_searchResults objectAtIndex:row];
	else
		return nil;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	OWTImageCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kWaterFlowCellID forIndexPath:indexPath];
	
	QJImageObject * asset = [self relatedAssetAtIndexPath:indexPath];
	
	cell.imageView.alpha = 0.0;
	
	if (asset != nil) {
		NSString * urlAdapt = [QJInterfaceManager thumbnailUrlFromImageUrl:asset.url size:CGSizeMake(_adaptWith, _adaptWith *[asset.height intValue] / [asset.width intValue])];
		
		__weak UIImageView * weakImageView = cell.imageView;
		[cell.imageView setImageWithURL:[NSURL URLWithString:urlAdapt]
		completed:^(UIImage * image, NSError * error, SDImageCacheType cacheType) {
			if (cacheType == SDImageCacheTypeNone)
				[UIView animateWithDuration:0.3
				animations:^{
					weakImageView.alpha = 1.0;
				}];
			else
				weakImageView.alpha = 1.0;
		}];
	}
	
	return cell;
}

// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	if (kind == kWaterFlowElementKindSectionHeader) {
		LJAssetInfoView * assetInfoViewa = [collectionView dequeueReusableSupplementaryViewOfKind:kWaterFlowElementKindSectionHeader withReuseIdentifier:@"AssetInfoViewa" forIndexPath:indexPath];
		
		for (UIView * view in assetInfoViewa.subviews)
			if (view.tag >= 500)
				[view removeFromSuperview];
				
		assetInfoViewa.imageType = _imageType;
		[assetInfoViewa customViewWithAsset:_imageAsset withOpen:_isOpen withController:self isLikeTrigger:_isLikeTap];
		_isLikeTap = _isLikeTap ? NO : NO;
		assetInfoViewa.canClick = YES;
		__weak OWTAssetViewCon * wself = self;
		assetInfoViewa.likeAction = ^{[wself likeButtonPressed]; };
		assetInfoViewa.reloadView = ^{[wself reloadData]; };
		assetInfoViewa.downloadAction = ^{[wself downloadAsset]; };
		assetInfoViewa.collectAction = ^{[wself collectAsset]; };
		assetInfoViewa.shareAction = ^{[wself shareAsset]; };
		assetInfoViewa.showAllCommentsAction = ^{[wself showAllAssetComments]; };
		assetInfoViewa.showOwnerUserAction = ^{[wself showOwnerUser]; };
		assetInfoViewa.reportAction = ^{[wself reportAsset]; };
		assetInfoViewa.showAction = ^{[wself showAssetAction]; };
		return assetInfoViewa;
	}
	
	return nil;
}

- (void)downloadAsset
{
	[SVProgressHUD showWithStatus:@"保存图片中..." maskType:SVProgressHUDMaskTypeBlack];
	SDWebImageManager * manager = [SDWebImageManager sharedManager];
	NSURL * url = [NSURL URLWithString:_imageAsset.url];
	[manager downloadWithURL:url
	options:SDWebImageHighPriority
	progress:nil
	completed:^(UIImage * image, NSError * error, SDImageCacheType cacheType, BOOL finished) {
		if (image != nil) {
			ALAssetsLibrary * assetsLibrary = [[ALAssetsLibrary alloc] init];
			[assetsLibrary saveImage:image
			toAlbum:@"全景"
			completion:^(NSURL * assetURL, NSError * error) {
				[SVProgressHUD showSuccessWithStatus:@"保存成功"];
			}
			failure:^(NSError * error) {
				[SVProgressHUD showSuccessWithStatus:@"保存成功"];
			}];
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				[[QJInterfaceManager sharedManager]requestImageAddDownload:_imageAsset.imageId
				imageType:_imageAsset.imageType];
			});
		}
		else {
			[SVProgressHUD showSuccessWithStatus:@"无法下载图片，请稍后再试。"];
		}
	}];
}

- (void)collectAsset
{
	OWTAuthManager * am = GetAuthManager();
	
	if (!am.isAuthenticated) {
		SIAlertView * alertView = [[SIAlertView alloc] initWithTitle:@"请登录" andMessage:@"收藏相关功能需要登录后使用"];
		[alertView addButtonWithTitle:@"登录"
		type:SIAlertViewButtonTypeDefault
		handler:^(SIAlertView * alertView) {
			dispatch_async(dispatch_get_main_queue(),
			^{
				[am showAuthViewConWithSuccess:^{
					// 写收藏
					dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
						NSError * error = [[QJInterfaceManager sharedManager] requestImageCollect:_imageAsset.imageId imageType:_imageAsset.imageType];
						dispatch_async(dispatch_get_main_queue(), ^{
							if (error == nil) {
								[SVProgressHUD showSuccessWithStatus:@"收藏成功"];
							}
							else {
								if (![NetStatusMonitor isExistenceNetwork]) {
									[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
									return;
								}
								[SVProgressHUD showErrorWithStatus:@"收藏失败"];
							}
						});
					});
				}
				cancel:^{}];
			});
			[alertView dismissAnimated:YES];
		}];
		
		[alertView addButtonWithTitle:@"取消"
		type:SIAlertViewButtonTypeCancel
		handler:^(SIAlertView * alertView) {
			[alertView dismissAnimated:YES];
		}];
		
		alertView.transitionStyle = SIAlertViewTransitionStyleFade;
		[alertView show];
	}
	else {
		// 写收藏
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSError * error = [[QJInterfaceManager sharedManager] requestImageCollect:_imageAsset.imageId imageType:_imageAsset.imageType];
			dispatch_async(dispatch_get_main_queue(), ^{
				if (error == nil) {
					[SVProgressHUD showSuccessWithStatus:@"收藏成功"];
				}
				else {
					if (![NetStatusMonitor isExistenceNetwork]) {
						[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
						return;
					}
					[SVProgressHUD showErrorWithStatus:@"收藏失败"];
				}
			});
		});
	}
}

- (void)shareAsset
{
	[SVProgressHUD showWithStatus:@"准备图片中..." maskType:SVProgressHUDMaskTypeBlack];
	
	NSString * url = [[QJInterfaceManager sharedManager] shareImageURLWithID:_imageAsset.imageId
		imageType:_imageAsset.imageType];
		
	[[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:_imageAsset.url]
	options:SDWebImageHighPriority
	progress:nil
	completed:^(UIImage * image, NSError * error, SDImageCacheType cacheType, BOOL finished) {
		if (error) {
			[SVProgressHUD showErrorWithStatus:@"获取图片失败"];
			return;
		}
		
		[SVProgressHUD dismiss];
		[UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
		[UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
		[UMSocialData defaultData].extConfig.wechatSessionData.url = url;
		[UMSocialData defaultData].extConfig.wechatTimelineData.url = url;
		[UMSocialData defaultData].extConfig.qqData.url = url;
		[UMSocialData defaultData].extConfig.qzoneData.url = url;
		NSString * title = nil;
		
		if (_imageAsset.tag)
			title = [NSString stringWithFormat:@"全景图片：%@", _imageAsset.tag];
		else
			title = @"全景图片";
			
		[UMSocialData defaultData].extConfig.qqData.title = title;
		[UMSocialData defaultData].extConfig.qzoneData.title = title;
		[UMSocialData defaultData].extConfig.wechatSessionData.title = title;
		[UMSocialData defaultData].extConfig.wechatTimelineData.title = title;
		
		[UMSocialSnsService presentSnsIconSheetView:self
		appKey:nil
		shareText:nil
		shareImage:image
		shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession, UMShareToWechatTimeline, UMShareToSina, UMShareToWechatFavorite, UMShareToQzone, UMShareToQQ, UMShareToSms, nil]
		delegate:nil];
	}];
}

- (void)showAllAssetComments
{
	[self commentButtonPressed];
}

- (void)showOwnerUser
{
	//    OWTUser* ownerUser = [GetUserManager() userForID:_asset.ownerUserID];
	//    //    NSLog(@"ddddddddddddddddd%@",_asset.ownerUserID);
	//    if (ownerUser != nil)
	//    {
	//
	//        OWTUserViewCon* userViewCon1 = [[OWTUserViewCon alloc] initWithNibName:nil bundle:nil];
	//        [self.navigationController pushViewController:userViewCon1 animated:YES];
	//        userViewCon1.user =ownerUser;
	//
	//    }
}

- (void)reportAsset
{
	OWTAssetManager * am = GetAssetManager();
	
	[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
	[am reportInappropriateAsset:_imageAsset
	success:^{
		[SVProgressHUD showSuccessWithStatus:@"感谢您的举报，我们会尽快处理！"];
	}
	failure:^(NSError * error) {
		[SVProgressHUD showErrorWithStatus:@"感谢您的举报，目前服务器有些问题，请稍后再试。"];
	}];
}

#pragma mark - Collection view delegate

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section
{
	NSArray * LikeBodys = _imageAsset.likes;
	
	if (section == 0) {
		CGFloat viewHeight = 0;
		float width = [_imageAsset.width floatValue];
		float height = [_imageAsset.height floatValue];
		float scr = SCREENWIT - 20;
		viewHeight += (10 + scr / width * height);
		// 四个按钮定制
		viewHeight += (10 + 30);
		
		// 标签 编号
		if ((_imageAsset.tag.length > 0) && (_imageAsset.descript == nil))
			viewHeight += 50;
		else if ((_imageAsset.descript.length > 0) && (_imageAsset.tag == nil))
			viewHeight += 50;
		else
			viewHeight += 30;
			
		// 喜欢的人
		CGFloat likeHeight = 0;
		CGFloat imageHeight = 20;
		
		if (LikeBodys.count != 0) {
			CGFloat likeWidth = 45;
			
			for (NSInteger i = 0; i < LikeBodys.count; i++) {
				if (likeWidth + imageHeight + 5 > SCREENWIT - 25) {
					likeWidth = 45;
					likeHeight += (imageHeight + 5);
				}
				likeWidth = likeWidth + imageHeight + 10;
			}
			
			likeHeight += imageHeight;
		}
		viewHeight += likeHeight;
		NSArray * comment = _imageAsset.comments;
		CGFloat commentHeight = 0;
		
		if (comment.count != 0) {
			viewHeight += 10;
			
			if (likeHeight != 0)
				viewHeight += 20;
				
			for (NSInteger i = 0; i < comment.count; i++) {
				QJCommentObject * commentModel = comment[i];
				NSString * name;
				
				if (commentModel.user.nickName)
					name = commentModel.user.nickName;
				else
					name = @"小熊";
				NSString * commentContent = [NSString stringWithFormat:@"%@", commentModel.comment];
				NSString * commentText = [NSString stringWithFormat:@"%@:%@", name, commentContent];
				CGSize size2 = [commentText sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(SCREENWIT - 75 - imageHeight, 500)];
				
				if (size2.height > imageHeight)
					commentHeight = commentHeight + size2.height + 5;
				else
					commentHeight = commentHeight + imageHeight + 5;
			}
		}
		else if (likeHeight != 0) {
			viewHeight += 10;
		}
		
		viewHeight += commentHeight;
		return viewHeight;
	}
	return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
	if (section == 0) {
		if (_jan == 1) {
			OWTAssetInfoView * calculatingAssetInfoView = self.assetInfoView;
			calculatingAssetInfoView.asset = _imageAsset;
			CGSize fittingSize = [calculatingAssetInfoView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
			CGFloat aspectRatio = fittingSize.height / fittingSize.width;
			fittingSize.width = self.view.bounds.size.width;
			fittingSize.height = ceil(fittingSize.width * aspectRatio);
			return fittingSize;
		}
		else {
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

- (OWTAssetInfoView *)assetInfoView
{
	if (_assetInfoView == nil) {
		UINib * headerNib = [UINib nibWithNibName:@"OWTAssetInfoView" bundle:nil];
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
- (OWTAssetInfoViewa *)assetInfoViewa
{
	if (_assetInfoViewa == nil) {
		UINib * headerNib = [UINib nibWithNibName:@"OWTAssetInfoViewa" bundle:nil];
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
	if (indexPath.section == 0) {
		QJImageObject * relatedAsset = [self relatedAssetAtIndexPath:indexPath];
		
		if ((relatedAsset != nil) && ([_imageType integerValue] == 1)) {
			OWTAssetViewCon * relatedAssetViewCon = [[OWTAssetViewCon alloc] initWithAsset:relatedAsset];
			[self.navigationController pushViewController:relatedAssetViewCon animated:YES];
		}
		else if (relatedAsset != nil) {
			OWTAssetViewCon * relatedAssetViewCon = [[OWTAssetViewCon alloc] initWithImageId:relatedAsset imageType:_imageType];
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
// 头像事件
- (void)showAssetAction
{
	NSMutableArray * array = [[NSMutableArray alloc]init];
	
	[array addObject:_imageAsset];
	float imageWith = SCREENWIT;
	float imagehigh = [_imageAsset.width floatValue] * imageWith / [_imageAsset.height floatValue];
	
	for (id object in _searchResults) {
		QJImageObject * asset1 = object;
		[array addObject:asset1];
	}
	
	NSMutableArray * FSArr = [[NSMutableArray alloc]init];
	
	for (int i = 0; i < array.count; i++) {
		QJImageObject * asset1 = array[i];
		NSString * adaptUrl = [QJInterfaceManager thumbnailUrlFromImageUrl:asset1.url size:CGSizeMake(imageWith, imagehigh)];
		FSBasicImage * firstPhoto = [[FSBasicImage alloc] initWithImageURL:[NSURL URLWithString:adaptUrl] name:asset1.captionCn];
		[FSArr addObject:firstPhoto];
	}
	
	FSBasicImageSource * photoSource = [[FSBasicImageSource alloc] initWithImages:FSArr];
	
	self.imageViewController = [[FSImageViewerViewController alloc] initWithImageSource:photoSource imageIndex:0 withViewController:self];
	
	self.imageViewController.navigationController.navigationBarHidden = YES;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	
		[self.navigationController presentViewController:_imageViewController animated:YES completion:nil];
	else
	
		[self.navigationController pushViewController:_imageViewController animated:YES];
}

// 底部的评论按钮事件
- (void)postComment:(NSString *)content
	success:(void (^)())success
	failure:(void (^)())failure
{
	[SVProgressHUD showWithStatus:@"发送评论中..." maskType:SVProgressHUDMaskTypeClear];
	
	RKObjectManager * om = [RKObjectManager sharedManager];
	[om postObject:nil
	path:[NSString stringWithFormat:@"assets1/%@/comments", _imageAsset.imageId]
	parameters:@{@"action" : @"addComment",
				 @"content" : content}
	success:^(RKObjectRequestOperation * o, RKMappingResult * result) {
		[o logResponse];
		
		NSDictionary * resultObjects = result.dictionary;
		OWTServerError * error = resultObjects[@"error"];
		
		if (error != nil) {
			[SVProgressHUD showServerError:error];
			
			if (failure != nil)
				failure();
				
			return;
		}
		
		OWTCommentData * commentData = resultObjects[@"comment"];
		
		if (commentData == nil) {
			[SVProgressHUD showGeneralError];
			
			if (failure != nil)
				failure();
				
			return;
		}
		
		OWTComment * comment = [OWTComment new];
		[comment mergeWithData:commentData];
		
		// [_asset addComment:comment];
		
		[_collectionView reloadData];
		
		if (success != nil)
			success();
	}
	failure:^(RKObjectRequestOperation * o, NSError * error) {
		[o logResponse];
		
		if (![NetStatusMonitor isExistenceNetwork])
			[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
		else
			[SVProgressHUD showError:error];
			
		if (failure != nil)
			failure();
	}
	];
}

- (void)loadMore
{}

@end
