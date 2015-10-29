//
//  OWTUserViewCon.m
//  Weitu
//
//  Created by Su on 4/12/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUserViewCon.h"
#import "OWTUserInfoView1.h"
#import "OWTUser.h"

#import "OWTUserManager.h"
#import "OWTUserInfoEditViewCon.h"
#import "OWTFont.h"
#import "OWTTabBarHider.h"
#import "OWTSettingsViewCon.h"
#import "OWTUserAssetsViewCon.h"
#import "OWTUserLikedAssetsViewCon.h"
#import "OWTFollowingUsersViewCon.h"
#import "OWTFollowerUsersViewCon.h"
#import "ORefreshControl.h"
#import "OWTAlbumViewCon.h"
#import "SVProgressHUD+WTError.h"
#import "UIViewController+WTExt.h"
#import "OWTAlbumInfoEditViewCon.h"
#import "OWTPhotoUploadInfoViewCon.h"
#import "OWTImageInfo.h"

#import <SHBarButtonItemBlocks/SHBarButtonItemBlocks.h>
#import <FontAwesomeKit/FontAwesomeKit.h>
#import <KHFlatButton/KHFlatButton.h>
#import <UIActionSheet-Blocks/UIActionSheet+Blocks.h>
#import <NBUImagePicker/NBUImagePicker.h>

#pragma mark -
#import "ORefreshControl.h"
#import "OWaterFlowLayout.h"
#import "OWTTabBarHider.h"
#import "OWaterFlowCollectionView.h"
#import "OWTImageCell.h"
#import "OWTAsset.h"
#import "UIView+EasyAutoLayout.h"
#import <SVPullToRefresh/SVPullToRefresh.h>

#import "OWTAssetViewCon.h"
#import "NetStatusMonitor.h"
#import "FSPhotoView.h"
#import "UIImageView+WebCache.h"

#import "DXMessageToolBar.h"
#import "ChatViewController_rename.h"
#import "ChatSendHelper.h"
#import "HuanXinManager.h"
#import "HXChatInitModel.h"
#import "UIViewController+HUD.h"
#import "DXChatBarMoreView.h"
#import "TTGlobalUICommon.h"
#import "RRConst.h"
static NSString * kWaterFlowCellID = @"kWaterFlowCellID";

#pragma mark -

@interface OWTUserViewCon () <DXMessageToolBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DXChatBarMoreViewDelegate, OWTUserInfoViewCareDelegate>
{
	UICollectionViewFlowLayout * _collectionViewLayout;
	UICollectionViewController * _collectionViewCon;
	UICollectionView * _collectionView;
	
	OWTTabBarHider * _tabBarHider;
	
	OWTUserInfoView1 * _userInfoView1;
	ChatViewController_rename * _chatVC;
	UIImagePickerController * _imagePicker;
	UITapGestureRecognizer * _tap;
	CGFloat _itemSize;
}

@property (nonatomic, strong) XHRefreshControl * refreshControl;
@property (strong, nonatomic) DXMessageToolBar * chatToolBar;

@end

@implementation OWTUserViewCon

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	if (self)
		[self setup];
	return self;
}

// data
- (NSMutableOrderedSet *)assets
{
	if ((self.user != nil) && (self.user.assetsInfo != nil) && (self.user.assetsInfo.assets != nil))
		return self.user.assetsInfo.assets;
	else
		return nil;
}

//
- (void)setup
{
	_chatToolBar.delegate = self;
	_chatVC = nil;
	_chatToolBar = nil;
	self.hidesBottomBarWhenPushed = YES;
	[self setupCollectionView];
	[self setupRefreshControl];
	self.view.backgroundColor = [UIColor whiteColor];
	__weak OWTUserViewCon * wself = self;
	wself.numberOfAssetsFunc = ^
	{
		NSMutableOrderedSet * assets = [wself assets];
		
		if (assets != nil)
			return (int)assets.count;
		else
			return 0;
	};
	wself.assetAtIndexFunc = ^(NSInteger index)
	{
		NSMutableOrderedSet * assets = [wself assets];
		
		if (assets != nil)
			return (OWTAsset *)[assets objectAtIndex:index];
		else
			return (OWTAsset *)nil;
	};
	
	wself.onAssetSelectedFunc = ^(OWTAsset * asset)
	{
		OWTAssetViewCon * assetViewCon = [[OWTAssetViewCon alloc] initWithAsset:asset deletionAllowed:YES onDeleteAction:^{[wself reloadData]; }];
		[wself.navigationController pushViewController:assetViewCon animated:YES];
	};
	wself.refreshDataFunc = ^(void (^ refreshDoneFunc)())
	{
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[[QJInterfaceManager sharedManager] requestUserImageList:_quser.uid
			pageNum:1
			pageSize:60
			currentImageId:nil
			finished:^(NSArray * imageObjectArray, BOOL isLastPage, NSArray * resultArray, NSError * error) {
				dispatch_async(dispatch_get_main_queue(), ^{
					if (error) {
						if (![NetStatusMonitor isExistenceNetwork])
							[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
						else
							[SVProgressHUD showError:error];
							
						if (refreshDoneFunc != nil)
							refreshDoneFunc();
						return;
					}
					
					if (refreshDoneFunc != nil)
						refreshDoneFunc();
				});
			}];
		});
		
		//		OWTUserManager * um = GetUserManager();
		//		[um refreshUserAssets:wself.user
		//		success:^{
		//			if (refreshDoneFunc != nil)
		//				refreshDoneFunc();
		//		}
		//		failure:^(NSError * error) {
		//			if (![NetStatusMonitor isExistenceNetwork])
		//				[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
		//			else
		//				[SVProgressHUD showError:error];
		//
		//			if (refreshDoneFunc != nil)
		//				refreshDoneFunc();
		//		}];
	};
	
	wself.loadMoreDataFunc = ^(void (^ loadMoreDoneFunc)()) {
		OWTUserManager * um = GetUserManager();
		[um loadMoreUserAssets:wself.user
		count:60
		success:^{
			if (loadMoreDoneFunc != nil)
				loadMoreDoneFunc();
		}
		failure:^(NSError * error) {
			[SVProgressHUD showError:error];
			
			if (loadMoreDoneFunc != nil)
				loadMoreDoneFunc();
		}];
	};
}

- (void)setupCollectionView
{
	UIScreen * screen = [UIScreen mainScreen];
	
	_itemSize = (screen.bounds.size.width - 30.0) / 3;
	
	_collectionView.backgroundColor = [UIColor redColor];
	
	_collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
	_collectionViewLayout.minimumLineSpacing = 5.0;
	_collectionViewLayout.minimumInteritemSpacing = 5.0;
	_collectionViewLayout.itemSize = CGSizeMake(_itemSize, _itemSize);
	
	_collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
	
	_collectionViewCon = [[UICollectionViewController alloc] initWithCollectionViewLayout:_collectionViewLayout];
	_collectionView = _collectionViewCon.collectionView;
	_collectionView.alwaysBounceVertical = YES;
	[self addChildViewController:_collectionViewCon];
	
	_collectionView.backgroundColor = GetThemer().themeColorBackground;
	_collectionView.delegate = self;
	_collectionView.dataSource = self;
	
	UINib * headerNib = [UINib nibWithNibName:@"OWTUserInfoView1" bundle:nil];
	
	[_collectionView registerNib:headerNib
	forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
	withReuseIdentifier:@"UserInfoView1"];
	
	// 图片
	
	[_collectionView registerClass:OWTImageCell.class forCellWithReuseIdentifier:kWaterFlowCellID];
}

- (void)setupRefreshControl
{
	_refreshControl = [[XHRefreshControl alloc] initWithScrollView:_collectionView delegate:self];
	
	__weak OWTUserViewCon * wself = self;
	[_collectionView addInfiniteScrollingWithActionHandler:^{[wself loadMoreData]; }];
	
	//    [_collectionView.infiniteScrollingView setState:SVInfiniteScrollingStateLoading];
	
	[_collectionView.infiniteScrollingView setState:SVInfiniteScrollingStateTriggered];
}

//

- (void)refreshData
{
	if (_refreshDataFunc == nil)
		return;
		
	_refreshDataFunc(^{
		[_refreshControl endPullDownRefreshing];
		[self reloadData];
	});
}

- (void)loadMoreData
{
	if (_loadMoreDataFunc == nil) {
		[_collectionView.infiniteScrollingView stopAnimating];
		return;
	}
	
	_loadMoreDataFunc(^
	{
		[_collectionView reloadData];
		[_collectionView.infiniteScrollingView stopAnimating];
	});
}

- (void)reloadData
{
	[_collectionView reloadData];
}

//
#pragma mark - OWaterFlowLayoutDataSource
- (OWTAsset *)assetAtIndex:(NSInteger)index
{
	if (_assetAtIndexFunc == nil)
		return nil;
		
	return _assetAtIndexFunc(index);
}

#pragma mark - UICollectionViewDataSource methods

#pragma mark - UICollectionViewDelegate methods

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

// called when the user taps on an already-selected item in multi-select mode
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
	if (_userInfoView1.ifCurrenUserEnter)
		[_chatToolBar setHidden:YES];
		
	if (!_userInfoView1.isCared && _rightTriggle)
		_chatToolBar.inputTextView.placeHolder = NSLocalizedString(@"发个消息认识Ta.....", @"input a new message");
}

//
- (void)viewDidLoad
{
	[super viewDidLoad];
	_tabBarHider = [[OWTTabBarHider alloc] init];
	[_tabBarHider hideTabBar];
	[self substituteNavigationBarBackItem];
	
	_chatVC.chatType = 0;
	[_chatVC.chatToolBar endEditing:YES];
}

//
//
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// [self substituteNavigationBarBackItem];
	//    if (_ifFirstEnter) {
	_collectionViewCon.view.frame = self.view.bounds;
	[self.view addSubview:_collectionViewCon.view];
	
	[self addChildViewController:_collectionViewCon];
	
	[_collectionViewCon.collectionView reloadData];
	[self initCustomchatBar];
	[self manualRefresh];
	//   }
}

// 返回按钮的代理方法
- (void)popViewControllerWithAnimation
{
	[self adealloc];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)initCustomchatBar
{
	[self.view addSubview:self.chatToolBar];
	_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden)];
	_tap.enabled = NO;
	[self.view addGestureRecognizer:_tap];
}

- (void)keyBoardHidden
{
	_tap.enabled = NO;
	[_chatToolBar endEditing:YES];
}

- (DXMessageToolBar *)chatToolBar
{
	if (_chatToolBar == nil) {
		_chatToolBar = [[DXMessageToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [DXMessageToolBar defaultHeight], self.view.frame.size.width, [DXMessageToolBar defaultHeight])];
		_chatToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
		_chatToolBar.delegate = self;
		_chatToolBar.userInteractionEnabled = YES;
		ChatMoreType type = ChatMoreTypeChat;
		_chatToolBar.moreView = [[DXChatBarMoreView alloc] initWithFrame:CGRectMake(0, (kVerticalPadding * 2 + kInputTextViewMinHeight), _chatToolBar.frame.size.width, 80) typw:type];
		_chatToolBar.moreView.backgroundColor = [UIColor lightGrayColor];
		_chatToolBar.moreView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
		[(DXChatBarMoreView *)_chatToolBar.moreView setDelegate:self];
		_chatToolBar.moreView.backgroundColor = HWColor(235, 235, 235);
		
		[_chatToolBar setToolbarBackground:HWColor(232, 232, 232)];
		_chatToolBar.ifEnable = true;
		_chatToolBar.getStatusBlock = ^{
			// TTAlertNoTitle(NSLocalizedString(@"关注成为好友后才能发消息！", @"Like Action First!"));
		};
	}
	
	return _chatToolBar;
}

#pragma -mark 初始化聊天资源
- (void)initHuanXinSource
{
	if (_chatVC)
		return;
		
	NSArray * array = [HXChatInitModel getCountAndPWDbyMD5];
	NSString * hxUsrId = [array firstObject];
	NSString * password = [array lastObject];
	
	// 登录检查
	if (![[EaseMob sharedInstance].chatManager isLoggedIn]) {
		[HuanXinManager sharedTool:hxUsrId passWord:password];
		return;
	}
	NSString * toChat = [@"qj" stringByAppendingString:_user.userID];
	// 开始聊天
	_chatVC = [[ChatViewController_rename alloc] initWithChatter:toChat isGroup:NO tile1:@"" title2:@""];
	_chatVC.title = _user.nickname;
	_chatVC.currentUserImage = GetUserManager().currentUser.currentImage;
	_chatVC.senderImage = _userInfoView1.mAvatarView.avatarImage;
}

- (BOOL)authouDetect
{
	if (!_userInfoView1.isCared && ![_userInfoView1.followingUsers containsObject:GetUserManager().currentUser.userID]) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			dispatch_async(dispatch_get_main_queue(), ^{
				[self keyBoardHidden];
				TTAlertNoTitle(NSLocalizedString(@"关注成为好友后才能发消息！", @"Like Action First!"));
			});
		});
		
		[_chatToolBar endEditing:YES];
		
		return false;
	}
	return YES;
}

#pragma mark - DXMessageToolBarDelegate 做权限检出和初始化聊天资源
- (void)inputTextViewWillBeginEditing:(XHMessageTextView *)messageInputTextView
{
	if ([self authouDetect]) {
		_chatToolBar.ifEnable = NO;
		[self initHuanXinSource];
		_tap.enabled = YES;
	}
	else {
		_chatToolBar.ifEnable = YES;
		[_chatToolBar endEditing:YES];
	}
}

#pragma mark - DXMessageToolBarDelegate
- (void)didSendText:(NSString *)text
{
	if (text && (text.length > 0)) {
		_chatVC.chatType = 1;
		_chatVC.bottomTextContend = text;
		[_chatToolBar endEditing:YES];
		[self.navigationController pushViewController:_chatVC animated:YES];
	}
}

- (UIImagePickerController *)imagePicker
{
	if (_imagePicker == nil) {
		_imagePicker = [[UIImagePickerController alloc] init];
		_imagePicker.modalPresentationStyle = UIModalPresentationOverFullScreen;
		_imagePicker.delegate = self;
	}
	
	return _imagePicker;
}

#pragma mark - UIImagePickerControllerDelegate 苹果API的回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage * orgImage = info[UIImagePickerControllerOriginalImage];
	
	[picker dismissViewControllerAnimated:YES completion:nil];
	
	if (orgImage) {
		[self inputTextViewWillBeginEditing:nil];
		_chatVC.chatType = 2;
		_chatVC.bootomPhotoContend = orgImage;
		[_chatToolBar endEditing:YES];
		[self.navigationController pushViewController:_chatVC animated:YES];
	}
}

#pragma mark - EMChatBarMoreViewDelegate 点击发图片触发的代理方法
- (void)moreViewPhotoAction:(DXChatBarMoreView *)moreView
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isShowPicker"];
	// 隐藏键盘
	[_chatToolBar endEditing:YES];
	
	// 弹出照片选择
	self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
	[self presentViewController:self.imagePicker animated:YES completion:NULL];
}

// 点击拍照片时 触发的方法
- (void)moreViewTakePicAction:(DXChatBarMoreView *)moreView
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isShowPicker"];
	[_chatToolBar endEditing:YES];
	
#if TARGET_IPHONE_SIMULATOR
		[self showHint:NSLocalizedString(@"message.simulatorNotSupportCamera", @"simulator does not support taking picture")];
#elif TARGET_OS_IPHONE
		self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
		[self presentViewController:self.imagePicker animated:YES completion:NULL];
#endif
}

- (void)adealloc
{
	_tap = nil;
	_chatToolBar.delegate = self;
	_chatVC = nil;
	_chatToolBar = nil;
	NSLog(@"userConview delloc method is called");
	
	_collectionViewLayout = nil;
	_collectionViewCon = nil;
	_collectionView = nil;
	
	_tabBarHider = nil;
	
	_imagePicker = nil;
	_refreshControl = nil;
	_chatToolBar = nil;
	_userInfoView1 = nil;
}

- (void)dealloc
{
	_tap = nil;
	_chatToolBar.delegate = self;
	_chatVC = nil;
	_chatToolBar = nil;
	NSLog(@"userConview delloc method is called");
	
	_collectionViewLayout = nil;
	_collectionViewCon = nil;
	_collectionView = nil;
	
	_tabBarHider = nil;
	
	_imagePicker = nil;
	_refreshControl = nil;
	_chatToolBar = nil;
	_userInfoView1 = nil;
}

//
- (void)manualRefresh
{
	[_refreshControl startPullDownRefreshing];
}

//

- (void)setUser:(OWTUser *)user
{
	_user = user;
	[self updateRightNavBarItem];
	[_collectionView reloadData];
}

- (void)updateRightNavBarItem
{
	[self.navigationController.navigationBar setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor whiteColor]}];
	self.navigationItem.title = @"用户信息";
	self.navigationItem.titleView = nil;
}

- (void)editUserInfo
{
	OWTUserInfoEditViewCon * userInfoEditViewCon = [[OWTUserInfoEditViewCon alloc] initWithNibName:nil bundle:nil];
	
	userInfoEditViewCon.user = _user;
	
	userInfoEditViewCon.cancelAction = ^{
		[self dismissViewControllerAnimated:YES completion:nil];
	};
	
	userInfoEditViewCon.doneFunc = ^{
		[self dismissViewControllerAnimated:YES completion:^{
			[self updateRightNavBarItem];
			[_collectionView reloadData];
		}];
	};
	
	UINavigationController * navCon = [[UINavigationController alloc] initWithRootViewController:userInfoEditViewCon];
	[self presentViewController:navCon animated:YES completion:nil];
}

- (void)refreshIfNeeded
{
	if (_user == nil)
		return;
		
	if (_user.isPublicInfoAvailable)
		return;
	//    [self loadMore];
}

// 开始刷新   这个作用  只是停止刷新
- (void)refresh
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[[QJPassport sharedPassport] requestOtherUserInfo:_quser.uid
		finished:^(QJUser * user, NSDictionary * userDic, NSError * error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (error) {
					[_refreshControl endPullDownRefreshing];
					[_collectionView reloadData];
					
					if (![NetStatusMonitor isExistenceNetwork])
						[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
					else
						[SVProgressHUD showError:error];
					return;
				}
				
				user.hasFollowUser = _quser.hasFollowUser;
				_quser = user;
				[_refreshControl endPullDownRefreshing];
				[_collectionView reloadData];
			});
		}];
	});
	
	//	OWTUserManager * um = GetUserManager();
	//	[um refreshPublicInfoForUser:_user
	//	success:^{
	//		[_refreshControl endPullDownRefreshing];
	//		//
	//
	//		[_collectionView reloadData];
	//	}
	//	failure:^(NSError * error) {
	//		[_refreshControl endPullDownRefreshing];
	//		[_collectionView reloadData];
	//
	//		if (![NetStatusMonitor isExistenceNetwork])
	//			[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
	//		else
	//			[SVProgressHUD showError:error];
	//	}];
}

// 后面是UI
#pragma mark - Collection View Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	if (section == 0) {
		return 0;
	}
	else if (section == 1) {
		if (_numberOfAssetsFunc == nil)
			return 0;
			
		return _numberOfAssetsFunc();
	}
	return 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:

// Album
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1) {
		OWTImageCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kWaterFlowCellID forIndexPath:indexPath];
		
		OWTAsset * asset = [self assetAtIndex:indexPath.row];
		
		if (asset != nil) {
			OWTImageInfo * imageInfo = asset.imageInfo;
			
			if (imageInfo != nil) {
				[cell.imageView setImageWithURL:[NSURL URLWithString:asset.imageInfo.smallURL] placeholderImage:[UIImage imageNamed:@""]];
			}
			else {
				[cell setImageWithInfo:nil];
				cell.backgroundColor = [UIColor lightGrayColor];
			}
		}
		
		return cell;
	}
	
	return nil;
}

// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	if (kind == UICollectionElementKindSectionHeader)
		if (indexPath.section == 0) {
			_userInfoView1 = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
				withReuseIdentifier:@"UserInfoView1"
				forIndexPath:indexPath];
				
			_userInfoView1.user = _quser;
			_userInfoView1.careDelegate = self;
			
			__weak OWTUserViewCon * wself = self;
			_userInfoView1.editUserInfoAction = ^{
				//                            [wself editUserInfo];
			};
			_userInfoView1.showAssetsAction = ^{[wself showAssets]; };
			_userInfoView1.showLikedAssetsAction = ^{[wself showLikedAssets]; };
			_userInfoView1.showFollowingsAction = ^{[wself showFollowings]; };
			_userInfoView1.showFollowersAction = ^{[wself showFollowers]; };
			_userInfoView1.showAvatorAction = ^{[wself showAvator]; };
			
			return _userInfoView1;
		}
		
	return nil;
}

#pragma mark - Collection view delegate
- (void)showAssets
{
	OWTUserAssetsViewCon * assetsViewCon = [[OWTUserAssetsViewCon alloc] initWithNibName:nil bundle:nil];
	
	assetsViewCon.user1 = _quser;
	
	[self.navigationController pushViewController:assetsViewCon animated:YES];
}

- (void)showLikedAssets
{
	OWTUserLikedAssetsViewCon * likedAssetsViewCon = [[OWTUserLikedAssetsViewCon alloc] initWithNibName:nil bundle:nil];
	
	likedAssetsViewCon.user = _user;
	[self.navigationController pushViewController:likedAssetsViewCon animated:YES];
}

- (void)showFollowings
{
	OWTFollowingUsersViewCon * followingUsersViewCon = [[OWTFollowingUsersViewCon alloc] initWithNibName:nil bundle:nil];
	
	followingUsersViewCon.user = _user;
	[self.navigationController pushViewController:followingUsersViewCon animated:YES];
}

- (void)showFollowers
{
	OWTFollowerUsersViewCon * followerUsersViewCon = [[OWTFollowerUsersViewCon alloc] initWithNibName:nil bundle:nil];
	
	followerUsersViewCon.user = _user;
	[self.navigationController pushViewController:followerUsersViewCon animated:YES];
}

- (void)showAvator
{
	[FSPhotoView showImageWithSenderViewWithUrl:_user.avatarImageInfo.url];
}

// album
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1)
		return CGSizeMake(_itemSize, _itemSize);
		
	return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
	if (section == 0)
		return CGSizeMake(320, 212);
		
	return CGSizeZero;
}

// album 点击事件
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1) {
		OWTAsset * asset = [self assetAtIndex:indexPath.row];
		
		if (asset != nil)
			if (_onAssetSelectedFunc != nil)
				_onAssetSelectedFunc(asset);
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

#pragma mark - 3rdparty refresh control

- (void)beginPullDownRefreshing
{
	[self refresh];
}

- (BOOL)keepiOS7NewApiCharacter
{
	return NO;
}

- (XHRefreshViewLayerType)refreshViewLayerType
{
	return XHRefreshViewLayerTypeOnScrollViews;
}

- (BOOL)isPullUpLoadMoreEnabled
{
	return NO;
}

#pragma mark - DXMessageToolBarDelegate

/**
 *  按下录音按钮开始录音
 */
- (void)didStartRecordingVoiceAction:(UIView *)recordView
{
	if ([self canRecord]) {
		DXRecordView * tmpView = (DXRecordView *)recordView;
		tmpView.center = self.view.center;
		[self.view addSubview:tmpView];
		[self.view bringSubviewToFront:recordView];
		
		NSError * error = nil;
		[[EaseMob sharedInstance].chatManager startRecordingAudioWithError:&error];
		
		if (error)
			NSLog(NSLocalizedString(@"message.startRecordFail", @"failure to start recording"));
	}
}

#pragma mark - private

- (BOOL)canRecord
{
	__block BOOL bCanRecord = YES;
	
	if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending) {
		AVAudioSession * audioSession = [AVAudioSession sharedInstance];
		
		if ([audioSession respondsToSelector:@selector(requestRecordPermission:)])
			[audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
				bCanRecord = granted;
			}];
	}
	
	return bCanRecord;
}

#pragma mark - DXMessageToolBarDelegate

/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction:(UIView *)recordView
{
	[[EaseMob sharedInstance].chatManager asyncCancelRecordingAudioWithCompletion:nil onQueue:nil];
}

#pragma mark - DXMessageToolBarDelegate 录音松手后的回调

/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceAction:(UIView *)recordView
{
	[[EaseMob sharedInstance].chatManager
	asyncStopRecordingAudioWithCompletion:^(EMChatVoice * aChatVoice, NSError * error) {
		if (!error) {
			[self inputTextViewWillBeginEditing:nil];
			_chatVC.chatType = 3;
			_chatVC.bootomVoiceContend = aChatVoice;
			
			[self.navigationController pushViewController:_chatVC animated:YES];
		}
		else {
			if (error.code == EMErrorAudioRecordNotStarted)
				[self showHint:error.domain yOffset:-40];
			else
				[self showHint:error.domain];
		}
	} onQueue:nil];
}

#pragma mark - OWTUserInfoViewCareDelegate

- (void)didCareButtonPressed:(BOOL)isCared
{
	if (isCared) {
		UIButton * rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 45.0, 17.0)];
		[rightBtn setTitle:@"已关注" forState:UIControlStateNormal];
		[rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		rightBtn.titleLabel.font = [UIFont systemFontOfSize:9.0];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
	}
	else {
		UIButton * rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 45.0, 17.0)];
		[rightBtn setImage:[UIImage imageNamed:@"圈子用户加关注.png"] forState:UIControlStateNormal];
		[rightBtn addTarget:self action:@selector(careButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
	}
}

- (void)careButtonPressed:(id)sender
{
	[_userInfoView1 careButtonPressed];
}

@end
