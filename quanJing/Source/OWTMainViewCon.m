//
//  OWTMainViewCon.m
//  Weitu
//
//  Created by Su on 3/8/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTMainViewCon.h"
#import "OWTFeedViewCon.h"
#import "OWTFeedManager.h"

#import "OWTSocialNavCon.h"
#import "OWTUserMeNavCon.h"
#import "OWTUserManager.h"
#import "OWTAuthManager.h"
#import "OQJNavCon.h"
#import "OWTFont.h"
#import "SVProgressHUD+WTError.h"
#import "UIView+EasyAutoLayout.h"
#import "OQJSelectedViewCon.h"
#import <NBUKit/UITabBarController+NBUAdditions.h>
#import <UIColor-HexString/UIColor+HexString.h>
#import <FontAwesomeKit/FAKFontAwesome.h>
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import <SIAlertView/SIAlertView.h>
#import <FXNotifications/FXNotifications.h>
#import <UIImage+RTTint/UIImage+RTTint.h>
#import "ChatListViewController.h"
#import "HuanXinManager.h"
#import "HXChatInitModel.h"
#import "NetStatusMonitor.h"
#import "OWTTabBarHider.h"

#import "PostFormData.h"
#import "RRConst.h"
#import "LJHomeViewCon.h"
#import "OWTAppDelegate.h"
#import "LJExploreViewController.h"
#import "LJExploreViewController1.h"
#import "QuanJingSDK.h"
#import "QJDatabaseManager.h"
#import "Reachability.h"
static const CGFloat kDefaultPlaySoundInterval = 3.0;

@interface OWTMainViewCon () <IChatManagerDelegate>
{
	NSString * _caption;
	ALAssetsLibrary * _assetsLibrary;
	
	Reachability * _reachability;
	BOOL _isWifi;
}

@property (nonatomic, weak) UIViewController * previousSelectedViewCon;
@property (strong, nonatomic) NSDate * lastPlaySoundDate;

@property (nonatomic, strong) OQJNavCon * homeNavCon;
@property (nonatomic, strong) OQJNavCon * exploreNavCon;
@property (nonatomic, strong) OQJNavCon * hxChatNavCon;

@property (nonatomic, strong) OQJNavCon * selectedNavCon;

@property (nonatomic, strong) OWTSocialNavCon * notificationViewCon;
@property (nonatomic, strong) OWTUserMeNavCon * userMeNavCon;

@property (nonatomic, strong) LJExploreViewController1 * exploreViewCon;
@property (nonatomic, strong) OQJSelectedViewCon * selectedViewCon;
@property (nonatomic, strong) ChatListViewController * chatListVC;

@property (nonatomic, strong) UIViewController * lastViewConBeforeCapture;
@end

@implementation OWTMainViewCon
{
	UIImageView * _tabBarImageView;
    OWTTabBarHider *_tabBar;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	if (self)
	
		[self setup];
		
	return self;
}

- (void)setup
{
	self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
	self.delegate = self;
    _tabBar=[[OWTTabBarHider alloc]init];
	[[NSNotificationCenter defaultCenter] addObserver:self
	selector:@selector(reachabilityChangedNotification:)
	name:kReachabilityChangedNotification object:nil];
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginStatusChange:) name:kQJUserNotLoginNotification object:nil];

	[self setupNetworkMonitor];
	
	GetThemer().homePageColor = HWColor(46, 46, 46);
	// 首页入口
	[self setupHomeViewCon];
	
	// 发现的入口
	[self setupExploreViewCon];
	
	//下面的这行代码 可能冗余
	[self setupSelectedViewCon];
	
	// 环信好友界面
	[self setupHuanXinIM];
	
	// 我的入口
	[self setupUserViewCon];
	
	// 把所有的导航控制器 塞到tarbar控制器中
	self.viewControllers = @[_homeNavCon, _exploreNavCon, _notificationViewCon, _userMeNavCon];
	
	[self setupTabBar];
	[self setUpDesignTabBar];
	[self addTarbarNotify];
	self.selectedViewController = _homeNavCon;
	
	self.edgesForExtendedLayout = UIRectEdgeTop;
	[self registerNotifications];
	_assetsLibrary = [[ALAssetsLibrary alloc]init];
}

- (void)setUpDesignTabBar
{
	NSArray * image1 = @[@"主页01", @"发现00", @"圈00", @"我00"];
	NSArray * image2 = @[@"主页00", @"发现01", @"圈01", @"我01"];
	
	_tabBarImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, SCREENHEI - 42, SCREENWIT, 42)];
	_tabBarImageView.userInteractionEnabled = YES;
	_tabBarImageView.backgroundColor = [UIColor blackColor];
	[self.view addSubview:_tabBarImageView];
	CGFloat point = SCREENWIT / 4;
	
	for (NSInteger i = 0; i < 4; i++) {
		UIImageView * imageView;
		imageView = [LJUIController createImageViewWithFrame:CGRectMake(0, 0, 25, 25) imageName:image1[i]];
		imageView.userInteractionEnabled = YES;
		imageView.tag = 500 + i;
		CGPoint point1 = CGPointMake(i * point + point / 2, 22);
		imageView.center = point1;
		[_tabBarImageView addSubview:imageView];
		
		if (i == 0)
			imageView.image = [UIImage imageNamed:image2[i]];
			
		UIButton * button = [LJUIController createButtonWithFrame:CGRectMake(i * point, 0, point, 42) imageName:nil title:nil target:self action:@selector(tapButton:)];
		button.tag = 500 + i;
		[_tabBarImageView addSubview:button];
	}
    _redPointView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"repoint"]];
    _redPointView.frame = CGRectMake(2 * point + point / 2+6, 10, 8, 8);
    [_redPointView setHidden:YES];
    NSUserDefaults * userDafault = [NSUserDefaults standardUserDefaults];
    NSNumber * num = [userDafault objectForKey:@"boxNewStatus"];
    if ([num boolValue])
    [_redPointView setHidden:NO];
	UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, 0.2)];
	label.backgroundColor = [UIColor blackColor];
	[_tabBarImageView addSubview:label];
    [label addSubview:_redPointView];
}

- (void)selectTap:(NSInteger)number
{
	NSArray * image1 = @[@"主页01", @"发现00", @"圈00", @"我00"];
	NSArray * image2 = @[@"主页00", @"发现01", @"圈01", @"我01"];
	
	for (UIView * view in _tabBarImageView.subviews) {
		if ([view isKindOfClass:[UILabel class]]) {
			UILabel * label = (UILabel *)view;
			
			if (view.tag == number)
				label.textColor = GetThemer().themeTintColor;
			else
				label.textColor = [UIColor blackColor];
		}
		
		if ([view isKindOfClass:[UIImageView class]]) {
			UIImageView * imageView = (UIImageView *)view;
			
			if (view.tag == number)
				imageView.image = [UIImage imageNamed:image2[view.tag - 500]]; else
				imageView.image = [UIImage imageNamed:image1[view.tag - 500]];
		}
	}
}

- (void)tapButton:(UIButton *)sender
{
	NSArray * image1 = @[@"主页01", @"发现00", @"圈00", @"我00"];
	NSArray * image2 = @[@"主页00", @"发现01", @"圈01", @"我01"];
    [_tabBar showTabBar];
	self.selectedIndex = sender.tag - 500;

	for (UIView * view in _tabBarImageView.subviews) {
		if ([view isKindOfClass:[UILabel class]]) {
			UILabel * label = (UILabel *)view;
			
			if (view.tag == sender.tag)
				label.textColor = GetThemer().themeTintColor;
			else
				label.textColor = [UIColor blackColor];
		}
		
		if ([view isKindOfClass:[UIImageView class]]) {
			UIImageView * imageView = (UIImageView *)view;
			
			if (view.tag == sender.tag)
				imageView.image = [UIImage imageNamed:image2[view.tag - 500]]; else
				imageView.image = [UIImage imageNamed:image1[view.tag - 500]];
		}
	}
	
	_previousSelectedViewCon = self.selectedViewController;
	
	if (sender.tag == 502) {
		OWTAuthManager * am = GetAuthManager();
		
		if (!am.isAuthenticated)
			[self showAuthViewCon];
		else
			[[NSNotificationCenter defaultCenter]postNotificationName:@"refreshFeed" object:nil];
	}
	
	//
	if (sender.tag == 503) {
		OWTAuthManager * am = GetAuthManager();
		
		if (!am.isAuthenticated) {
			[self showAuthViewCon];
		}
		else {
			OWTUserManager * um = GetUserManager();
			
			if ([QJPassport sharedPassport].currentUser == nil) {
				[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
				
				[um refreshCurrentUserSuccess:^{
					[SVProgressHUD dismiss];
					self.selectedViewController = _notificationViewCon;
				}
				failure:^(NSError * error) {
					NSInteger code = error.code;
					
					if ((code == -1011) || (code == kWTErrorAuthFailed)) {
						[SVProgressHUD dismiss];
						[self showAuthViewCon];
					}
					else {
						if (![NetStatusMonitor isExistenceNetwork])
							[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
						else
							[SVProgressHUD showError:error];
					}
				}];
			}
		}
	}
}

// 全景
- (void)setupHomeViewCon
{
	//    OWTHomeFeedViewCon *_homeFeedViewCon = [[OWTHomeFeedViewCon alloc] initWithNibName:nil bundle:nil];
	LJHomeViewCon * _homeFeedViewCon = [[LJHomeViewCon alloc]init];
	
	_homeNavCon = [[OQJNavCon alloc] initWithRootViewController:_homeFeedViewCon];
	
	_homeNavCon.ifCustomColor = NO;
	OWTFont * icon = [OWTFont altHomeIconWithSize:32];
	icon.drawingPositionAdjustment = UIOffsetMake(0, -2);
	UIImage * tabBarIcon = [icon imageWithSize:CGSizeMake(32, 32)];
	_homeNavCon.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"全景" image:tabBarIcon selectedImage:nil];
}

// 发现
- (void)setupExploreViewCon
{
	//    _exploreViewCon = [[OQJExploreViewCon alloc] initWithNibName:nil bundle:nil];
	//    _exploreViewCon=[[LJExploreViewController alloc]init];
	_exploreViewCon = [[LJExploreViewController1 alloc]init];
	_exploreNavCon = [[OQJNavCon alloc] initWithRootViewController:_exploreViewCon];
	
	OWTFont * icon = [OWTFont compassIconWithSize:32];
	icon.drawingPositionAdjustment = UIOffsetMake(0, -2);
	UIImage * tabBarIcon = [icon imageWithSize:CGSizeMake(32, 32)];
	_exploreNavCon.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"活动" image:tabBarIcon selectedImage:nil];
}

// 圈子
- (void)setupSelectedViewCon
{
	_notificationViewCon = [[OWTSocialNavCon alloc] initWithNibName:nil bundle:nil];
	_notificationViewCon.navigationBar.translucent = NO;
}

//
- (void)setupHuanXinIM
{
	_chatListVC = [[ChatListViewController alloc]init];
	_hxChatNavCon = [[OQJNavCon alloc] initWithRootViewController:_chatListVC];
	OWTFont * icon = [OWTFont pictureIconWithSize:32];
	icon.drawingPositionAdjustment = UIOffsetMake(0, -2);
	UIImage * tabBarIcon = [icon imageWithSize:CGSizeMake(32, 32)];
	_hxChatNavCon.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"消息" image:tabBarIcon selectedImage:nil];
	// _hxChatNavCon.navigationBar.barTintColor = HWColor(46, 46, 46);
	
	OWTAppDelegate * delegate = (OWTAppDelegate *)[UIApplication sharedApplication].delegate;
	delegate.hxChatNavCon = _hxChatNavCon;
}

#pragma mark - 检测网络

- (void)setupNetworkMonitor
{
	_reachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
	_isWifi = _reachability.isReachableViaWiFi;
	[_reachability startNotifier];
}

- (void)reachabilityChangedNotification:(NSNotification *)notification
{
	Reachability * reachability = [notification object];
	
	if (![reachability isKindOfClass:[Reachability class]])
		return;
		
	NetworkStatus netStatus = [reachability currentReachabilityStatus];
	_isWifi = (netStatus == kReachableViaWiFi);
}

// 我
#pragma mark - User View 我的模块
- (void)setupUserViewCon
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picRecNize:) name:@"recogNizePhoto" object:nil];
	_userMeNavCon = [[OWTUserMeNavCon alloc] initWithNibName:nil bundle:nil];
	OWTFont * icon = [OWTFont userIconWithSize:32];
	icon.drawingPositionAdjustment = UIOffsetMake(0, -2);
	//	UIImage * tabBarIcon = [icon imageWithSize:CGSizeMake(32, 32)];
	
	_userMeNavCon.navigationBar.translucent = NO;
}

- (void)picRecNize:(NSNotification *)notification
{
	NSArray * array = (NSArray *)notification.userInfo;
	
	[self asigo:array];
}

- (void)asigo:(id)obj
{
	NSArray * array = (NSArray *)obj;
	
	if (!array || (array.count == 0))
		return;
		
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		QJDatabaseManager * manager = [QJDatabaseManager sharedManager];
		
		for (NSInteger i = array.count - 1; i >= 0; i--) {
			while (!_isWifi)
				[NSThread sleepForTimeInterval:2.0];
				
			NSDictionary * dict = array[i];
			__weak QJDatabaseManager * weakManager = manager;
			[manager performDatabaseUpdateBlock:^(NSManagedObjectContext * concurrencyContext) {
				QJImageCaption * model = [weakManager getImageCaptionByUrl:dict[@"imageurl"]
				context:concurrencyContext];
				
				// 若本地没有 发起网络请求并
				if ((model == nil) || model.isSelfInsert.boolValue)
					[self getResouceWithImageUrl:dict[@"imageurl"]
					model:model
					context:concurrencyContext];
			}
			finished:^(NSManagedObjectContext * mainContext) {
				dispatch_semaphore_signal(sem);
			}];
			dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		}
	});
}

- (void)getResouceWithImageUrl:(NSString *)imageUrl
	model:(QJImageCaption *)model
	context:(NSManagedObjectContext *)context
{
	// 获取图片缩略图
	ALAssetsLibrary * assetsLibrary = [[ALAssetsLibrary alloc] init];
	__block ALAsset * asset = nil;
	
	dispatch_semaphore_t sem = dispatch_semaphore_create(0);
	
	[assetsLibrary assetForURL:[NSURL URLWithString:imageUrl]
	resultBlock:^(ALAsset * resultAsset) {
		asset = resultAsset;
		dispatch_semaphore_signal(sem);
	}
	failureBlock:^(NSError * error) {
		dispatch_semaphore_signal(sem);
	}];
	dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
	
	if (!asset || ![[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto])
		return;
		
	UIImage * image = [UIImage imageWithCGImage:asset.thumbnail];
	NSData * data = UIImageJPEGRepresentation(image, 1.0f);
	NSString * imageurl = [data base64Encoding];
	
	// 上传图片获取Tag
	NSError * error = nil;
	NSData * mData = [PostFormData bulidPostFormData:imageurl forKey:@"base64"];
	
	NSString * strUrl = @"http://api.tiankong.com/qjapi/pictag";
	NSURL * url = [NSURL URLWithString:strUrl];
	
	NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
	request.HTTPMethod = @"POST";
	[request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	request.HTTPBody = mData;
	
	NSURLResponse * reponse = [[NSURLResponse alloc] init];
	NSData * received = [NSURLConnection sendSynchronousRequest:request returningResponse:&reponse error:&error];
	
	if (!error && received) {
		NSMutableString * caption = [[NSMutableString alloc]init];
		NSDate * date = [asset valueForProperty:ALAssetPropertyDate];
		NSString * timeCap = [NSString stringWithFormat:@"%@", date];
		
		if (timeCap.length > 0)
			[caption appendFormat:@" %@", [self getTheTime:timeCap]];
			
		NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableContainers error:nil];
		NSArray * arr = dict[@"scene_understanding"][@"matches"];
		
		for (NSDictionary * dict1 in arr) {
			if (dict1 == arr[0])
				[caption appendString:[NSString stringWithFormat:@" %@ ", dict1[@"tag"]]];
			else
				[caption appendString:[NSString stringWithFormat:@"%@ ", dict1[@"tag"]]];
				
			NSArray * adviseCaptionArray = [[QJDatabaseManager sharedManager] getAdviseCaptionsByCaption:dict1[@"tag"] context:context];
			
			if (!adviseCaptionArray)
				[[QJDatabaseManager sharedManager] setAdviseCaptionByImageUrl:imageUrl
				caption:dict1[@"tag"]
				number:[NSNumber numberWithLong:1]
				context:context];
			else
				[adviseCaptionArray enumerateObjectsUsingBlock:^(QJAdviseCaption * obj, NSUInteger idx, BOOL * stop) {
					NSInteger num = obj.number.integerValue;
					obj.number = [NSNumber numberWithInteger:num + 1];
				}];
		}
		
		NSLog(@"拿到的 caption：%@", caption);
		
		if (model && model.isSelfInsert) {
			[caption appendString:[NSString stringWithFormat:@" %@", _caption]];
			model.caption = caption;
		}
		else {
			[[QJDatabaseManager sharedManager] setImageCaptionByImageUrl:imageUrl
			caption:caption
			isSelfInsert:NO
			context:context];
		}
	}
}

- (NSString *)getTheTime:(NSString *)date
{
	NSArray * arr = [date componentsSeparatedByString:@"-"];
	NSString * month = arr[1];
	NSInteger monthDate = month.intValue;
	NSString * timeCap = [NSString stringWithFormat:@"%@ %ld月", arr[0], (long)monthDate];
	
	return timeCap;
}

- (void)setupTabBar
{
	self.tabBar.tintColor = [UIColor colorWithHexString:@"#33bbff"];
	
	self.tabBar.translucent = NO;
	
	for (UITabBarItem * item in self.tabBar.items) {
		item.titlePositionAdjustment = UIOffsetMake(0, -2);
		[item setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:12]}
		forState:UIControlStateNormal];
	}
	
	[self setupWaterflowScrollActions];
}

- (void)addTarbarNotify
{
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		// 隐藏tarbar
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideCustomTabBar) name:@"hideCustomTabBar"object:nil];
		
		// 显示tarbar
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCustomTabBar) name:@"showCustomTabBar"object:nil];
	});
}

// 隐藏tabbar
- (void)hideCustomTabBar
{
	_tabBarImageView.hidden = YES;
}

- (void)showCustomTabBar
{
	_tabBarImageView.hidden = NO;
}

- (void)setupWaterflowScrollActions
{
	NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
	
	[nc postNotificationName:@"kWTHideMainTabBarNotification" object:nil];
#if 0
		[nc addObserver:self
		forName:kWTScrollUpNotification
		object:nil
		queue:[NSOperationQueue mainQueue]
		usingBlock:^(NSNotification * notification, id observer) {
		if (!self.isTabBarHidden)
			[self setTabBarHidden:YES animated:YES];
	}];
	
		[nc addObserver:self
		forName:kWTScrollDownNotification
		object:nil
		queue:[NSOperationQueue mainQueue]
		usingBlock:^(NSNotification * notification, id observer) {
		if (self.isTabBarHidden)
			[self setTabBarHidden:YES animated:YES];
	}];
#endif

	[nc addObserver:self
	forName:kWTShowMainTabBarNotification
	object:nil
	queue:[NSOperationQueue mainQueue]
	usingBlock:^(NSNotification * notification, id observer) {
		self.tabBar.hidden = YES;
		_tabBarImageView.hidden = NO;
	}];
	
	[nc addObserver:self
	forName:kWTHideMainTabBarNotification
	object:nil
	queue:[NSOperationQueue mainQueue]
	usingBlock:^(NSNotification * notification, id observer) {
		self.tabBar.hidden = YES;
		_tabBarImageView.hidden = YES;
	}];
	
	[nc addObserver:self
	forName:kWTLoggedOutNotification
	object:nil
	queue:[NSOperationQueue mainQueue]
	usingBlock:^(NSNotification * notification, id observer) {
		[self onLoggedOut];
	}];
}

// tabbar隐藏
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

#pragma mark - Home View

#pragma mark - Notification View

- (void)showAuthViewCon
{
	OWTAuthManager * am = GetAuthManager();
	__weak OWTMainViewCon * weakself = self;
	
	am.cancelBlock = ^{
		weakself.selectedIndex = 0;
		[weakself selectTap:500];
	};
	[am showAuthViewConWithSuccess:^{
		self.userMeNavCon.photolistview.user = GetUserManager().currentUser;
		self.selectedIndex = 3;
		[self selectTap:503];
	}
	cancel:^{
		OWTUserManager * um = GetUserManager();
		self.userMeNavCon.photolistview.user = um.currentUser;
		self.selectedIndex = 0;
		[self selectTap:500];
	}];
}

#pragma mark - TabBarController Delegate

- (UIImage *)createViewShotImage:(UIView *)view
{
	CGRect bounds = view.bounds;
	
	UIGraphicsBeginImageContextWithOptions(bounds.size, YES, 0.0);
	[view drawViewHierarchyInRect:bounds afterScreenUpdates:YES];
	UIImage * viewShotImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return viewShotImage;
}

#pragma -mark 登陆检查
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
	_previousSelectedViewCon = self.selectedViewController;
	
	if (viewController == _userMeNavCon) {
		OWTAuthManager * am = GetAuthManager();
		
		if (!am.isAuthenticated) {
			[self showAuthViewCon];
			return NO;
		}
		else {
			//			OWTUserManager * um = GetUserManager();
			//            if (um.currentUser == nil)
			//            {
			//                [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
			//
			//                [um refreshCurrentUserSuccess:^{
			//                    [SVProgressHUD dismiss];
			//                    self.userMeNavCon.userViewCon.photolistview.user = um.currentUser;
			//                    self.selectedViewController = _userMeNavCon;
			//                }
			//                                      failure:^(NSError* error) {
			//                                          NSInteger code = error.code;
			//                                          if (code == -1011 || code == kWTErrorAuthFailed)
			//                                          {
			//                                              [SVProgressHUD dismiss];
			//                                              [self showAuthViewCon];
			//                                          }
			//                                          else
			//                                          {
			//                                              [SVProgressHUD showError:error];
			//                                          }
			//                                      }];
			//                return NO;
			//            }
			//            else
			//            {
			// self.userMeNavCon.photolistview.user = um.currentUser;
			//            }
		}
	}
	
	//
	if (viewController == _notificationViewCon) {
		OWTAuthManager * am = GetAuthManager();
		
		if (!am.isAuthenticated) {
			[self showAuthViewCon];
			return NO;
		}
		else {
			OWTUserManager * um = GetUserManager();
			
			if (um.currentUser == nil) {
				[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
				
				[um refreshCurrentUserSuccess:^{
					[SVProgressHUD dismiss];
					self.selectedViewController = _notificationViewCon;
				}
				failure:^(NSError * error) {
					NSInteger code = error.code;
					
					if ((code == -1011) || (code == kWTErrorAuthFailed)) {
						[SVProgressHUD dismiss];
						[self showAuthViewCon];
					}
					else {
						if (![NetStatusMonitor isExistenceNetwork])
							[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
						else
							[SVProgressHUD showError:error];
					}
				}];
				return NO;
			}
		}
	}
	
	// 环信聊天登陆检查
	if (viewController == _hxChatNavCon) {
		OWTAuthManager * am = GetAuthManager();
		
		if (!am.isAuthenticated) {
			[self showAuthViewCon];
			return NO;
		}
		else {
			OWTUserManager * um = GetUserManager();
			
			if (um.currentUser == nil) {
				[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
				
				[um refreshCurrentUserSuccess:^{
					[SVProgressHUD dismiss];
					self.selectedViewController = _hxChatNavCon;
				}
				failure:^(NSError * error) {
					NSInteger code = error.code;
					
					if ((code == -1011) || (code == kWTErrorAuthFailed)) {
						[SVProgressHUD dismiss];
						[self showAuthViewCon];
					}
					else {
						if (![NetStatusMonitor isExistenceNetwork])
							[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
						else
							[SVProgressHUD showError:error];
					}
				}];
				return NO;
			}
		}
	}
	
	return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{}

#pragma mark - Notification Handling

- (void)onLoggedOut
{
	_tabBarImageView.hidden = NO;
	self.selectedIndex = 0;
	[self selectTap:500];
}

// 收到消息回调
- (void)didReceiveMessage:(EMMessage *)message
{
	BOOL needShowNotification = message.isGroup ?[self needShowNotification:message.conversationChatter] : YES;
	
	if (needShowNotification) {
		// #if !TARGET_IPHONE_SIMULATOR
		
		BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
		//如果app在后台 震动加声音
        if (!isAppActivity){
			[self showNotificationWithMessage:message];
            [self playSoundAndVibration];
        }
		else
            [self playVibration];
		// #endif
	}
	
	// 解决chatList刷新问题
	[_chatListVC refreshDataSource];
}

- (BOOL)needShowNotification:(NSString *)fromChatter
{
	BOOL ret = YES;
	NSArray * igGroupIds = [[EaseMob sharedInstance].chatManager ignoredGroupIds];
	
	for (NSString * str in igGroupIds)
		if ([str isEqualToString:fromChatter]) {
			ret = NO;
			break;
		}
		
	return ret;
}

- (void)playSoundAndVibration
{
	NSTimeInterval timeInterval = [[NSDate date]
		timeIntervalSinceDate:self.lastPlaySoundDate];
		
	if (timeInterval < kDefaultPlaySoundInterval) {
		// 如果距离上次响铃和震动时间太短, 则跳过响铃
		NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
		return;
	}
	
	// 保存最后一次响铃时间
	self.lastPlaySoundDate = [NSDate date];
	
	// 收到消息时，播放音频
	[[EaseMob sharedInstance].deviceManager asyncPlayNewMessageSound];
	// 收到消息时，震动
	[[EaseMob sharedInstance].deviceManager asyncPlayVibration];
}

- (void)playVibration
{
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    
    if (timeInterval < kDefaultPlaySoundInterval) {
        // 如果距离上次响铃和震动时间太短, 则跳过响铃
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
        return;
    }
    
    // 保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
    
    // 收到消息时，播放音频
//    [[EaseMob sharedInstance].deviceManager asyncPlayNewMessageSound];
    // 收到消息时，震动
    [[EaseMob sharedInstance].deviceManager asyncPlayVibration];
    //去设置圈子里的红点 － 显示
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setRedPointStatus" object:nil userInfo:(NSDictionary*)[NSNumber numberWithBool:YES]];
     [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:YES] forKey:@"boxNewStatus"];
     [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)showNotificationWithMessage:(EMMessage *)message
{
	EMPushNotificationOptions * options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
	// 发送本地推送
	UILocalNotification * notification = [[UILocalNotification alloc] init];
	
	notification.fireDate = [NSDate date];	// 触发通知的时间
	
	if (options.displayStyle == ePushNotificationDisplayStyle_messageSummary) {
		id <IEMMessageBody> messageBody = [message.messageBodies firstObject];
		NSString * messageStr = nil;
		switch (messageBody.messageBodyType) {
			case eMessageBodyType_Text:
				{
					messageStr = ((EMTextMessageBody *)messageBody).text;
				}
				break;
				
			case eMessageBodyType_Image:
				{
					messageStr = NSLocalizedString(@"message.image", @"Image");
				}
				break;
				
			case eMessageBodyType_Location:
				{
					messageStr = NSLocalizedString(@"message.location", @"Location");
				}
				break;
				
			case eMessageBodyType_Voice:
				{
					messageStr = NSLocalizedString(@"message.voice", @"Voice");
				}
				break;
				
			case eMessageBodyType_Video:
				{
					messageStr = NSLocalizedString(@"message.vidio", @"Vidio");
				}
				break;
				
			default:
				break;
		}
		
		NSString * title = message.from;
		
		if (message.isGroup) {
			NSArray * groupArray = [[EaseMob sharedInstance].chatManager groupList];
			
			for (EMGroup * group in groupArray)
				if ([group.groupId isEqualToString:message.conversationChatter]) {
					title = [NSString stringWithFormat:@"%@(%@)", message.groupSenderName, group.groupSubject];
					break;
				}
		}
		
		notification.alertBody = [NSString stringWithFormat:@"%@:%@", title, messageStr];
	}
	else {
		notification.alertBody = NSLocalizedString(@"receiveMessage", @"you have a new message");
	}
	
	// 去掉注释会显示[本地]开头, 方便在开发中区分是否为本地推送
	// notification.alertBody = [[NSString alloc] initWithFormat:@"[本地]%@", notification.alertBody];
	
	notification.alertAction = NSLocalizedString(@"open", @"Open");
	notification.timeZone = [NSTimeZone defaultTimeZone];
	notification.soundName = UILocalNotificationDefaultSoundName;
	// 发送通知
	[[UIApplication sharedApplication] scheduleLocalNotification:notification];
	UIApplication * application = [UIApplication sharedApplication];
	application.applicationIconBadgeNumber += 1;
}

#pragma mark - public  收到本地推送后 直接进入聊天页面
- (void)jumpToChatList
{
    /*//[[NSNotificationCenter defaultCenter] postNotificationName:@"setRedPointStatus" object:nil userInfo:(NSDictionary*)[NSNumber numberWithBool:YES]];
*/
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	
	if (_chatListVC) {
		[self.navigationController popToViewController:self animated:NO];
		@try {
			[self presentViewController:_hxChatNavCon animated:NO completion:nil];
		}
		@catch(NSException * exception) {
			NSLog(@"异常的原因： %@", exception);
		}
	}
}

- (void)registerNotifications
{
	[self unregisterNotifications];
	[[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

- (void)unregisterNotifications
{
	[[EaseMob sharedInstance].chatManager removeDelegate:self];
}

#pragma mark - IChatManagerDelegate 登录状态变化
- (void)didLoginFromOtherDevice
{
	[[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:NO completion:^(NSDictionary * info, EMError * error) {
		UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"loginAtOtherDevice", @"your login account has been in other places") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
		alertView.tag = 100;
		[alertView show];
		[[QJPassport sharedPassport] logout];
	} onQueue:nil];
}

- (void)loginStatusChange:(NSNotification *)sender
{
	if ([QJPassport sharedPassport].isLogin) {
		[[QJPassport sharedPassport]logout];
		[self showAuthViewCon];
	}
}

/* [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:NO completion:^(NSDictionary *info, EMError *error) {
 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"loginAtOtherDevice", @"your login account has been in other places") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
 alertView.tag = 100;
 [alertView show];
 
 } onQueue:nil];*/
@end
