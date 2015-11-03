//
//  OAppDelegate.m
//  Weitu
//
//  Created by Su on 3/8/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTAppDelegate.h"
#import "OWTMainViewCon.h"
#import "OWTAccessToken.h"

#import "OWTUserManager.h"
#import "OWTDataManager.h"
#import "OWTAuthManager.h"
#import "OWTFeedManager.h"
#import "OWTCategoryManager.h"
#import "OWTAssetManager.h"
#import "OWTActivityManager.h"
#import "OWTCategoryManagerlife.h"
#import "OWTCategoryManagerlvyou.h"
#import "OWTSearchManager.h"
#import "OWTCategoryManagerlvyouinternational.h"
#import "OWTCategoryManagershishang.h"
#import "OWTCategoryManagerqiche.h"
#import "OWTCategoryManagermeishi.h"
#import "OWTCategoryManagerjiaju.h"
#import "OWTCategoryManagerbaike.h"
#import <CocoaLumberjack/DDTTYLogger.h>

#import "MobClick.h"
#import "Crittercism.h"
#import "HXLoginStatus.h"
#import "StartViewController.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaHandler.h"
#import "UIColor+HexString.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "QJDatabaseManager.h"
#import "QuanJingSDK.h"
@interface OWTAppDelegate ()


@property (nonatomic, strong) OWTMainViewCon * mainViewCon;

@end

@implementation OWTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[[QJDatabaseManager sharedManager] databaseInitialize];

    // deviceId
#ifdef DEBUG
    [QJBaseManager setKeyChainAccessGroup:nil];
#else
    [QJBaseManager setKeyChainAccessGroup:@"T3BNK5WMQ7.com.quanjing.device.identifier"];
#endif
    
	[Fabric with:@[[Crashlytics class]]];
	[self setup];
	
	UIScreen * screen = [UIScreen mainScreen];
	self.window = [[UIWindow alloc] initWithFrame:screen.bounds];
	self.window.tintColor = GetThemer().themeTintColor;
	self.window.backgroundColor = [UIColor colorWithRed:235 / 255.0 green:235 / 255.0 blue:235 / 255.0 alpha:1.0];
	NSString * userPhoneName = [[UIDevice currentDevice] name];
	NSLog(@"手机别名: %@", userPhoneName);
	NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *str=[userDefaults objectForKey:@"version"];
    NSString *str1= [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    if ([str isEqualToString:str1]) {
        OWTMainViewCon *mainView=[[OWTMainViewCon alloc]initWithNibName:nil bundle:nil];
        mainView.tabBar.hidden=YES;
        self.window.rootViewController=mainView;
    }else
    {
        StartViewController *svc=[[StartViewController alloc]init];
        self.window.rootViewController=svc;
        [userDefaults setObject:str1 forKey:@"version"];
    }
	[self.window makeKeyAndVisible];
	return YES;
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{}

/*
*/

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	NSInteger cont = application.applicationIconBadgeNumber;
	
	if (cont > 0)
		if (_mainViewCon)
			[_mainViewCon jumpToChatList];
}

#pragma mark - Setup

- (void)setup
{
	[self setupThemer];
	[self setupLogger];
	[self setupManagers];
	[self setupShareSDK];
	[self setupUMengAnalytics];
	[self setupCrittercism];
	[self setupHXStatus];
	[self initHuanXinSDK];
}

- (void)initHuanXinSDK
{
	NSDictionary * dic = [[NSUserDefaults standardUserDefaults]objectForKey:@"HxChatData"];
	
	if (dic) {
		// [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"HxChatData"];
		// [[NSUserDefaults standardUserDefaults]synchronize];
	}
	
	[[EaseMob sharedInstance] registerSDKWithAppKey:@"panorama#quanjing" apnsCertName:@"huanXinAPNPush"];
	[self registerRemoteNotification];
}

- (void)setupHXStatus
{
	HXLoginStatus * hxStatus = [[HXLoginStatus alloc]init];
	
	self.hxStatus = hxStatus;
}

- (void)setupThemer
{
	_themer = [[OWTGlobalThemer alloc] init];
	[_themer apply];
}

- (void)setupLogger
{
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
}

- (void)setupManagers
{
	_dataManager = [[OWTDataManager alloc] init];
	_authManager = [[OWTAuthManager alloc] init];
	_userManager = [[OWTUserManager alloc] init];
	_feedManager = [[OWTFeedManager alloc] init];
	_categoryManager = [[OWTCategoryManager alloc] init];
	
	_assetManager = [[OWTAssetManager alloc] init];
	_activityManager = [[OWTActivityManager alloc] init];
	
	_searchManager = [[OWTSearchManager alloc] init];
	
	_categoryManagerlife = [[OWTCategoryManagerlife alloc] init];
	
	// 六大板块
	_categoryManagerlvyou = [[OWTCategoryManagerlvyou alloc] init];
	_categoryManagerlvyouinternational = [[OWTCategoryManagerlvyouinternational alloc] init];
	_categoryManagershishang = [[OWTCategoryManagershishang alloc] init];
	_categoryManagerqiche = [[OWTCategoryManagerqiche alloc] init];
	_categoryManagermeishi = [[OWTCategoryManagermeishi alloc] init];
	_categoryManagerjiaju = [[OWTCategoryManagerjiaju alloc] init];
	_categoryManagerbaike = [[OWTCategoryManagerbaike alloc] init];
}

- (void)setupShareSDK
{	// 友盟的appkey
	[UMSocialData setAppKey:@"53f9f64efd98c56a4c04cb99"];
	// 微信的appkey
	[UMSocialWechatHandler setWXAppId:@"wxd38f9d0119a4fcc4" appSecret:@"c69879f1d25cd22877670ff61309b2e7" url:@"http://www.umeng.com/social"];
	// qq的appkey
	[UMSocialQQHandler setQQWithAppId:@"1103410983" appKey:@"sF1AZahQ09LQ35l5" url:@"http://www.umeng.com/social"];
	// 新浪的分享
	[UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
}

- (void)setupUMengAnalytics
{
	NSString * kWTUMengAppKey = @"53f9f64efd98c56a4c04cb99";
	NSString * channelID;
	
#if DEBUG
		channelID = @"DebugBuild";
#else
		channelID = @"";
#endif

	[MobClick startWithAppkey:kWTUMengAppKey reportPolicy:SEND_INTERVAL channelId:channelID];
	
}


- (void)setupCrittercism
{
	[Crittercism enableWithAppID:@"537d9cb828ae454447000001"];
}

#pragma mark - Simple testing
// 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application
	didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	[[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

// 打印收到的apns信息
- (void)didReiveceRemoteNotificatison:(NSDictionary *)userInfo
{
	NSError * parseError = nil;
	NSData * jsonData = [NSJSONSerialization dataWithJSONObject:userInfo
		options:NSJSONWritingPrettyPrinted error:&parseError];
	NSString * str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"推送内容"
		message:str
		delegate:nil
		cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
		otherButtonTitles:nil];
		
	[alert show];
}

// 注册deviceToken失败，此处失败，与环信SDK无关，一般是您的环境配置或者证书配置有误
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	[[EaseMob sharedInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.failToRegisterApns", Fail to register apns)
		message:error.description
		delegate:nil
		cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
		otherButtonTitles:nil];
	[alert show];
}

// 注册推送
- (void)registerRemoteNotification
{
	UIApplication * application = [UIApplication sharedApplication];
	
	application.applicationIconBadgeNumber = 0;
	
	if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
		UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
		UIUserNotificationSettings * settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
		[application registerUserNotificationSettings:settings];
	}
	
#if !TARGET_IPHONE_SIMULATOR
		// iOS8 注册APNS
		if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
			[application registerForRemoteNotifications];
		}
		else {
			UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
				UIRemoteNotificationTypeSound |
				UIRemoteNotificationTypeAlert;
			[[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
		}
#endif
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	UIView * a = [[UIView alloc]init];
	
	a.frame = CGRectMake(100, 100, 100, 100);
	a.backgroundColor = [UIColor blueColor];
	[application.keyWindow addSubview:a];
	
	if (_mainViewCon)
		[_mainViewCon jumpToChatList];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
	if (_mainViewCon)
		[_mainViewCon jumpToChatList];
		
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
	if (_mainViewCon)
		[_mainViewCon jumpToChatList];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	return [UMSocialSnsService handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application
	openURL:(NSURL *)url
	sourceApplication:(NSString *)sourceApplication
	annotation:(id)annotation
{
	return [UMSocialSnsService handleOpenURL:url];
}

@end
