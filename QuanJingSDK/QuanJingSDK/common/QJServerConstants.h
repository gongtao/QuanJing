//
//  QJServerConstants.h
//  QuanJingSDK
//
//  Created by QJ on 15/10/20.
//  Copyright © 2015年 QJ. All rights reserved.
//

#ifndef QJServerConstants_h
#define QJServerConstants_h

#import <Foundation/Foundation.h>

// 域名地址
static NSString * const kQJServerURL = @"http://123.57.175.151:8080";

// 发送注册短息
static NSString * const kQJUserSendRegistSMSPath = @"/user/smsRegistered";

// 注册用户
static NSString * const kQJUserRegisterPath = @"/user/regist";

// 登录用户
static NSString * const kQJUserLoginPath = @"/user/login";

// 用户信息
static NSString * const kQJUserInfoPath = @"/user/info.user";

// 修改用户信息
static NSString * const kQJUserInfoModifyPath = @"/user/update.user";

// 首页
static NSString * const kQJHomeIndexPath = @"/index";

// 搜索
static NSString * const kQJSearchPath = @"/search";

// 图片分类
static NSString * const kQJImageCategoryPath = @"/imageCategory/root";

// 圈子列表
static NSString * const kQJActionListPath = @"/imageCategory/root";

#endif	/* QJServerConstants_h */
