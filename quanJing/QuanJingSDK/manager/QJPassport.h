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

@property (nonatomic, strong, nullable) QJUser * currentUser;

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
- (void)loginUser:(NSString *)userName
	password:(NSString *)password
	finished:(void (^)(NSNumber * userId, NSString * ticket, NSError * error))finished;
	
// 发送登录短信
- (NSError *)sendLoginSMS:(NSString *)phoneNumber;

// 短信登录
- (void)loginUser:(NSString *)phoneNumber
	code:(NSString *)code
	finished:(void (^)(NSNumber * userId, NSString * ticket, NSError * error))finished;
	
// 判断是否登录
- (BOOL)isLogin;

// 注销
- (void)logout;

// 用户信息查询
- (void)requestUserInfo:(nullable void (^)(QJUser * user, NSDictionary * userDic, NSError * error))finished;

// 用户信息修改
- (void)requestModifyUserInfo:(QJUser *)user
	finished:(nullable void (^)(QJUser * user, NSDictionary * userDic, NSError * error))finished;
	
// 用户关注列表
- (void)requestUserFollowList:(nullable NSNumber *)userId
	pageNum:(NSUInteger)pageNum
	pageSize:(NSUInteger)pageSize
	finished:(nullable void (^)(NSArray * followUserArray, BOOL isLastPage, NSArray * resultArray, NSError * error))finished;
	
@end

NS_ASSUME_NONNULL_END
