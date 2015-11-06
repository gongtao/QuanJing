
//
//  HuanXinManager.m
//  dreamJobs
//
//  Created by denghs on 15/3/21.
//  Copyright (c) 2015年 Renrui. All rights reserved.
//

#import "HuanXinManager.h"
#import "EaseMob.h"
#import "TTGlobalUICommon.h"
#import "ChatSendHelper.h"
#import "HXLoginStatus.h"

#define HXKAIFA  @"APNS_DEVELOP"
#define HXFAXING @"APNS_PRODUCT" 
static HuanXinManager *_instance = nil;
#define reConnectCnt  7
@implementation HuanXinManager
{
    EMConversation *conversation;
}

+(id)allocWithZone:(struct _NSZone *)zone{
    //调用dispatch_once保证在多线程中也只被实例化一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+(instancetype)sharedTool:(NSString*)appUsrId passWord:(NSString*)pass{
   // static dispatch_once_t onceToken;
   // dispatch_once(&onceToken, ^{
        _instance = [[HuanXinManager alloc] init];
        [self initHuanXinSDK];
        [self loginHuanXin:appUsrId password:pass];
    //});
    return _instance;
}

-(id)copyWithZone:(NSZone *)zone{
    return _instance;
}

#pragma -mark 切换账号后重新登录
+(void)reloginDifUser:(NSString*)appUsrId passWord:(NSString*)pass
{
    [self login:appUsrId password:pass];

}

#pragma -mark 初始化 环信接口
+(void)initHuanXinSDK
{
    HXLoginStatus *status = GetHXStatus();
    //如果已经初始化成功 返回
    if (status.initStatus) {
        NSLog(@"如果已经初始化成功 返回");
        return;
    }
   EMError* error =  [[EaseMob sharedInstance] registerSDKWithAppKey:@"panorama#quanjing"
                              apnsCertName:@"huanXinAPNPush"
                              otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];
    //初始化失败 弹出告警框
    if (error) {
          TTAlertNoTitle(NSLocalizedString(@"网络失败1", @"Connect to the server failed!"));
        return;
    }
    status.initStatus = true;
}


//
#pragma -mark 登陆环信
+(void)loginHuanXin:(NSString*)usrNmae password:(NSString*)password
{
    //如果已经登陆
    if ([[EaseMob sharedInstance].chatManager isLoggedIn]) {
        return;
    }
    [self login:usrNmae password:password];
    
}

+(void)login:(NSString*)usrNmae password:(NSString*)password
{
    //失败后 重练7次
    static NSInteger connectCnt = reConnectCnt;
    //异步登陆账号
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:usrNmae
                                                        password:password
                                                      completion:
     ^(NSDictionary *loginInfo, EMError *error) {
         if (loginInfo && (!error) ) {
             [[[EaseMob sharedInstance] chatManager] asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
                 if (!error) {
                     //TTAlertNoTitle(error.description);
                 }
             } onQueue:nil];
             
        //设置自动登录
         }else {
             switch (error.errorCode) {
                 case EMErrorServerNotReachable:
                    if (connectCnt<1) {
//                         TTAlertNoTitle(NSLocalizedString(@"服务异常,请重新启动", @"Connect to the server failed!"));
                     }
                     //再次重连
                     else
                     {
                        connectCnt--;
                        [self login:usrNmae password:password];
                     }
                     break;
                 case EMErrorServerAuthenticationFailure:
//                     TTAlertNoTitle(error.description);
                     break;
                 case EMErrorServerTimeout:
//                     TTAlertNoTitle(NSLocalizedString(@"网络失败.", @"Connect to the server timed out!"));
                     break;
                 default:
//                     TTAlertNoTitle(NSLocalizedString(@"网络失败..", @"Logon failure"));
                     break;
             }
         }
     } onQueue:nil];

}

/* if (reConnectCnt<1) {
 
 TTAlertNoTitle([[@"第几次重连接" stringByAppendingFormat:@"%i",reConnectCnt] stringByAppendingString: NSLocalizedString(@"网络失败2", @"Connect to the server failed!") ] );
 }
 else
 {
 reConnectCnt--;
 [self login:usrNmae password:password];
 
 }*/
//环信登出
+(void)logoutHuanxin
{
    EMError *error = nil;
    NSDictionary *dic = [[EaseMob sharedInstance].chatManager logoffWithUnbindDeviceToken:NO error:&error];
    NSLog(@"注销环信的信息 %@",dic);
}
@end
