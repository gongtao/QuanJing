//
//  HuanXinManager.h
//  dreamJobs
//
//  Created by denghs on 15/3/21.
//  Copyright (c) 2015年 Renrui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HuanXinManager : NSObject

//初始化 环信SDK
+(void)initHuanXinSDK;
//从服务器 获取APP和客服 在环信上的账号关系
-(NSDictionary*)getIMrefelct;

//使用从服务器获取到的映射表 登陆环信
-(void)loginHuanXin:(NSDictionary*)count;

-(void)login:(NSString*)usrName password1:(NSString*)passwork;

//聊天完毕 登出环信服务器 回收chat资源
+(void)logoutHuanxin;

+(instancetype)sharedTool:(NSString*)appUsrId passWord:(NSString*)pass;

//切换账号
+(void)reloginDifUser:(NSString*)appUsrId passWord:(NSString*)pass;
@end
