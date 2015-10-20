//
//  QJPassport.h
//  QuanJingSDK
//
//  Created by QJ on 15/10/20.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QJUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface QJPassport : NSObject

+ (instancetype)sharedPassport;

///-------------------
/// @name 全景用户接口
///-------------------

// 发送注册短信
- (NSError *)sendRegistSMS:(NSString *)phoneNumber;

// 注册用户
- (void)registerUser:(NSString *)phoneNumber
            password:(NSString *)password
                code:(NSString *)code
            finished:(nullable void (^)(QJUser * user, NSDictionary * userDic, NSError * error))finished;

// 登录
- (NSError *)loginUser:(NSString *)userName password:(NSString *)password;

// 判断是否登录
- (BOOL)isLogin;

// 注销
- (void)logout;

// 用户信息查询
- (void)requestUserInfo:(nullable void (^)(QJUser * user, NSDictionary * userDic, NSError * error))finished;

// 用户信息修改
- (void)requestModifyUserInfo:(QJUser *)user
                     finished:(nullable void (^)(QJUser * user, NSDictionary * userDic, NSError * error))finished;

@end

NS_ASSUME_NONNULL_END
