//
//  QJPassport.m
//  QuanJingSDK
//
//  Created by QJ on 15/10/20.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import "QJPassport.h"

#import "QJCoreMacros.h"

#import "QJServerConstants.h"

#import "QJHTTPManager.h"

#import "QJUtils.h"

#define kCookieDictionaryKey @"kCookieDictionaryKey"

@implementation QJPassport

+ (instancetype)sharedPassport
{
	static QJPassport * sharedPassport = nil;
	static dispatch_once_t t;
	
	dispatch_once(&t, ^{
		sharedPassport = [[QJPassport alloc] init];
	});
	return sharedPassport;
}

- (instancetype)init
{
	self = [super init];
	
	if (self)
		[self loadURLCookie];
	return self;
}

#pragma mark - Private

- (void)loadURLCookie
{
	NSMutableDictionary * cookieDic = [[NSUserDefaults standardUserDefaults] objectForKey:kCookieDictionaryKey];
	
	if (QJ_IS_DICT_NIL(cookieDic))
		return;
		
	NSHTTPCookie * cookie = [NSHTTPCookie cookieWithProperties:cookieDic];
	NSHTTPCookieStorage * cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	[cookieJar setCookie:cookie];
}

- (void)saveURLCookie
{
	NSURL * url = [NSURL URLWithString:kQJServerURL];
	NSHTTPCookieStorage * cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray * cookies = [cookieJar cookiesForURL:url];
	
	__block NSDictionary * cookieDic = nil;
	
	[cookies enumerateObjectsUsingBlock:^(NSHTTPCookie * cookie, NSUInteger idx, BOOL * stop) {
		if ([cookie.name isEqualToString:@"ticket"]) {
			cookieDic = [NSDictionary dictionaryWithObjectsAndKeys:cookie.name, NSHTTPCookieName,
			cookie.value, NSHTTPCookieValue,
			cookie.path, NSHTTPCookiePath,
			cookie.domain, NSHTTPCookieDomain,
			nil];
			*stop = YES;
		}
	}];
	
	if (QJ_IS_DICT_NIL(cookieDic))
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:kCookieDictionaryKey];
	else
		[[NSUserDefaults standardUserDefaults] setObject:cookieDic forKey:kCookieDictionaryKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Property

- (AFHTTPClient *)httpRequestManager
{
	return [[QJHTTPManager sharedManager] httpRequestManager];
}

#pragma mark - 注册

- (NSError *)sendRegistSMS:(NSString *)phoneNumber
{
	NSParameterAssert(phoneNumber);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	params[@"phoneNumber"] = phoneNumber;
	
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJUserSendRegistSMSPath
		parameters:params
		success:^(AFHTTPRequestOperation * operation, id resultResponseObject) {
			NSLog(@"%@", operation.request.URL);
			responseObject = resultResponseObject;
			dispatch_semaphore_signal(sem);
		}
		failure:^(AFHTTPRequestOperation * operation, NSError * resultError) {
			NSLog(@"%@", operation.request.URL);
			error = resultError;
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		
		if (!error)
			error = [QJUtils errorFromOperation:responseObject];
		i--;
	} while (error && i >= 0);
	
	if (!error)
		NSLog(@"%@", responseObject);
		
	return error;
}

- (void)registerUser:(NSString *)phoneNumber
	password:(NSString *)password
	code:(NSString *)code
	finished:(void (^)(NSNumber * userId, NSString * ticket, NSError * error))finished
{
	NSParameterAssert(phoneNumber);
	NSParameterAssert(password);
	NSParameterAssert(code);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	params[@"phoneNumber"] = phoneNumber;
	params[@"passWord"] = password;
	params[@"code"] = code;
	
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJUserRegisterPath
		parameters:params
		success:^(AFHTTPRequestOperation * operation, id resultResponseObject) {
			NSLog(@"%@", operation.request.URL);
			responseObject = resultResponseObject;
			dispatch_semaphore_signal(sem);
		}
		failure:^(AFHTTPRequestOperation * operation, NSError * resultError) {
			NSLog(@"%@", operation.request.URL);
			error = resultError;
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		
		if (!error)
			error = [QJUtils errorFromOperation:responseObject];
		i--;
	} while (error && i >= 0);
	
	if (!error) {
		NSLog(@"%@", responseObject);
		NSDictionary * data = responseObject[@"data"];
		NSNumber * userId = data[@"userId"];
		
		if (!self.currentUser)
			self.currentUser = [[QJUser alloc] init];
		self.currentUser.uid = userId;
		
		[self saveURLCookie];
		
		if (finished)
			finished(userId, data[@"ticket"], error);
		return;
	}
	
	if (finished)
		finished(nil, nil, error);
}

#pragma mark - 登录

- (void)loginUser:(NSString *)userName
	password:(NSString *)password
	finished:(void (^)(NSNumber * userId, NSString * ticket, NSError * error))finished
{
	NSParameterAssert(userName);
	NSParameterAssert(password);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	params[@"userName"] = userName;
	params[@"passWord"] = password;
	
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJUserLoginPath
		parameters:params
		success:^(AFHTTPRequestOperation * operation, id resultResponseObject) {
			NSLog(@"%@", operation.request.URL);
			responseObject = resultResponseObject;
			dispatch_semaphore_signal(sem);
		}
		failure:^(AFHTTPRequestOperation * operation, NSError * resultError) {
			NSLog(@"%@", operation.request.URL);
			error = resultError;
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		
		if (!error)
			error = [QJUtils errorFromOperation:responseObject];
		i--;
	} while (error && i >= 0);
	
	if (!error) {
		NSLog(@"%@", responseObject);
		NSDictionary * data = responseObject[@"data"];
		NSNumber * userId = data[@"userId"];
		
		if (!self.currentUser)
			self.currentUser = [[QJUser alloc] init];
		self.currentUser.uid = userId;
		
		[self saveURLCookie];
		
		if (finished)
			finished(userId, data[@"ticket"], error);
		return;
	}
	
	if (finished)
		finished(nil, nil, error);
}

- (NSError *)sendLoginSMS:(NSString *)phoneNumber
{
	NSParameterAssert(phoneNumber);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	params[@"phoneNumber"] = phoneNumber;
	
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJUserSendLoginSMSPath
		parameters:params
		success:^(AFHTTPRequestOperation * operation, id resultResponseObject) {
			NSLog(@"%@", operation.request.URL);
			responseObject = resultResponseObject;
			dispatch_semaphore_signal(sem);
		}
		failure:^(AFHTTPRequestOperation * operation, NSError * resultError) {
			NSLog(@"%@", operation.request.URL);
			error = resultError;
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		
		if (!error)
			error = [QJUtils errorFromOperation:responseObject];
		i--;
	} while (error && i >= 0);
	
	if (!error)
		NSLog(@"%@", responseObject);
		
	return error;
}

// 短信登录
- (void)loginUser:(NSString *)phoneNumber
	code:(NSString *)code
	finished:(void (^)(NSNumber * userId, NSString * ticket, NSError * error))finished
{
	NSParameterAssert(phoneNumber);
	NSParameterAssert(code);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	params[@"phoneNumber"] = phoneNumber;
	params[@"code"] = code;
	
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJUserLoginSMSPath
		parameters:params
		success:^(AFHTTPRequestOperation * operation, id resultResponseObject) {
			NSLog(@"%@", operation.request.URL);
			responseObject = resultResponseObject;
			dispatch_semaphore_signal(sem);
		}
		failure:^(AFHTTPRequestOperation * operation, NSError * resultError) {
			NSLog(@"%@", operation.request.URL);
			error = resultError;
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		
		if (!error)
			error = [QJUtils errorFromOperation:responseObject];
		i--;
	} while (error && i >= 0);
	
	if (!error) {
		NSLog(@"%@", responseObject);
		NSDictionary * data = responseObject[@"data"];
		NSNumber * userId = data[@"userId"];
		
		if (!self.currentUser)
			self.currentUser = [[QJUser alloc] init];
		self.currentUser.uid = userId;
		
		[self saveURLCookie];
		
		if (finished)
			finished(userId, data[@"ticket"], error);
		return;
	}
	
	if (finished)
		finished(nil, nil, error);
}

- (BOOL)isLogin
{
	__block BOOL isLogin = NO;
	NSURL * url = [NSURL URLWithString:kQJServerURL];
	NSHTTPCookieStorage * cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray * cookies = [cookieJar cookiesForURL:url];
	
	[cookies enumerateObjectsUsingBlock:^(NSHTTPCookie * cookie, NSUInteger idx, BOOL * stop) {
		if ([cookie.name isEqualToString:@"ticket"]) {
			isLogin = YES;
			*stop = YES;
		}
	}];
	return isLogin;
}

#pragma mark - 注销

- (void)logout
{
	NSURL * url = [NSURL URLWithString:kQJServerURL];
	NSHTTPCookieStorage * cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray * cookies = [cookieJar cookiesForURL:url];
	
	[cookies enumerateObjectsUsingBlock:^(NSHTTPCookie * cookie, NSUInteger idx, BOOL * stop) {
		[cookieJar deleteCookie:cookie];
	}];
	
	self.currentUser = nil;
	
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kCookieDictionaryKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 用户信息

- (void)requestUserInfo:(void (^)(QJUser * user, NSDictionary * userDic, NSError * error))finished
{
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJUserInfoPath
		parameters:nil
		success:^(AFHTTPRequestOperation * operation, id resultResponseObject) {
			NSLog(@"%@", operation.request.URL);
			responseObject = resultResponseObject;
			dispatch_semaphore_signal(sem);
		}
		failure:^(AFHTTPRequestOperation * operation, NSError * resultError) {
			NSLog(@"%@", operation.request.URL);
			error = resultError;
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		
		if (!error)
			error = [QJUtils errorFromOperation:responseObject];
		i--;
	} while (error && i >= 0);
	
	if (!error) {
		NSLog(@"%@", responseObject);
		NSDictionary * dataDic = responseObject[@"data"];
		
		if (self.currentUser)
			[self.currentUser setPropertiesFromJson:dataDic];
		else
			self.currentUser = [[QJUser alloc] initWithJson:dataDic];
			
		if (finished)
			finished(self.currentUser, dataDic, error);
		return;
	}
	
	if (finished)
		finished(self.currentUser, nil, error);
}

// 其他用户信息查询
- (void)requestOtherUserInfo:(NSNumber *)userId
	finished:(nullable void (^)(QJUser * user, NSDictionary * userDic, NSError * error))finished
{
	NSParameterAssert(userId);
	
	NSString * url = [NSString stringWithFormat:kQJOtherUserInfoPath, userId];
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:url
		parameters:nil
		success:^(AFHTTPRequestOperation * operation, id resultResponseObject) {
			NSLog(@"%@", operation.request.URL);
			responseObject = resultResponseObject;
			dispatch_semaphore_signal(sem);
		}
		failure:^(AFHTTPRequestOperation * operation, NSError * resultError) {
			NSLog(@"%@", operation.request.URL);
			error = resultError;
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		
		if (!error)
			error = [QJUtils errorFromOperation:responseObject];
		i--;
	} while (error && i >= 0);
	
	if (!error) {
		NSLog(@"%@", responseObject);
		NSDictionary * dataDic = responseObject[@"data"];
		
		if (self.currentUser)
			[self.currentUser setPropertiesFromJson:dataDic];
		else
			self.currentUser = [[QJUser alloc] initWithJson:dataDic];
			
		if (finished)
			finished(self.currentUser, dataDic, error);
		return;
	}
	
	if (finished)
		finished(self.currentUser, nil, error);
}

- (void)requestModifyUserInfo:(QJUser *)user
	finished:(nullable void (^)(QJUser * user, NSDictionary * userDic, NSError * error))finished
{
	NSParameterAssert(user);
	NSParameterAssert(user.uid);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	params[@"userId"] = user.uid;
	
	// qq
	if (!QJ_IS_STR_NIL(user.qq))
		params[@"qq"] = user.qq;
		
	// realName
	if (!QJ_IS_STR_NIL(user.realName))
		params[@"realName"] = user.realName;
		
	// nickName
	if (!QJ_IS_STR_NIL(user.nickName))
		params[@"nickName"] = user.nickName;
		
	// email
	if (!QJ_IS_STR_NIL(user.email))
		params[@"email"] = user.email;
		
	// avatar
	if (!QJ_IS_STR_NIL(user.avatar))
		params[@"avatar"] = user.avatar;
		
	// gender
	if (!QJ_IS_NUM_NIL(user.gender))
		params[@"gender"] = user.gender;
		
	// age
	if (!QJ_IS_STR_NIL(user.age))
		params[@"age"] = user.age;
		
	// job
	if (!QJ_IS_STR_NIL(user.job))
		params[@"job"] = user.job;
		
	// maritalStatus
	if (!QJ_IS_STR_NIL(user.maritalStatus))
		params[@"maritalStatus"] = user.maritalStatus;
		
	// interest
	if (!QJ_IS_STR_NIL(user.interest))
		params[@"interest"] = user.interest;
		
	// starSign
	if (!QJ_IS_STR_NIL(user.starSign))
		params[@"starSign"] = user.starSign;
		
	// bornArea
	if (!QJ_IS_STR_NIL(user.bornArea))
		params[@"bornArea"] = user.bornArea;
		
	// residence
	if (!QJ_IS_STR_NIL(user.residence))
		params[@"residence"] = user.residence;
		
	// stayArea
	if (!QJ_IS_STR_NIL(user.stayArea))
		params[@"stayArea"] = user.stayArea;
		
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager postPath:kQJUserInfoModifyPath
		parameters:params
		success:^(AFHTTPRequestOperation * operation, id resultResponseObject) {
			NSLog(@"%@", operation.request.URL);
			responseObject = resultResponseObject;
			dispatch_semaphore_signal(sem);
		}
		failure:^(AFHTTPRequestOperation * operation, NSError * resultError) {
			NSLog(@"%@", operation.request.URL);
			error = resultError;
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		
		if (!error)
			error = [QJUtils errorFromOperation:responseObject];
		i--;
	} while (error && i >= 0);
	
	if (!error) {
		NSLog(@"%@", responseObject);
		NSDictionary * dataDic = responseObject[@"data"];
		
		if (self.currentUser)
			[self.currentUser setPropertiesFromJson:dataDic];
		else
			self.currentUser = [[QJUser alloc] initWithJson:dataDic];
			
		if (finished)
			finished(self.currentUser, dataDic, error);
		return;
	}
	
	if (finished)
		finished(self.currentUser, nil, error);
}

#pragma mark - 用户关注

- (void)requestUserFollowList:(NSNumber *)userId
	pageNum:(NSUInteger)pageNum
	pageSize:(NSUInteger)pageSize
	finished:(nullable void (^)(NSArray * followUserArray, BOOL isLastPage, NSArray * resultArray, NSError * error))finished
{
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	
	if (!QJ_IS_NUM_NIL(userId))
		params[@"userId"] = userId;
		
	if (pageNum == 0)
		pageNum = 1;
	params[@"pageNum"] = [NSNumber numberWithUnsignedInteger:pageNum];
	
	if (pageSize > 0)
		params[@"pageSize"] = [NSNumber numberWithUnsignedInteger:pageSize];
		
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJUserFollowListPath
		parameters:params
		success:^(AFHTTPRequestOperation * operation, id resultResponseObject) {
			NSLog(@"%@", operation.request.URL);
			responseObject = resultResponseObject;
			dispatch_semaphore_signal(sem);
		}
		failure:^(AFHTTPRequestOperation * operation, NSError * resultError) {
			NSLog(@"%@", operation.request.URL);
			error = resultError;
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		
		if (!error)
			error = [QJUtils errorFromOperation:responseObject];
		i--;
	} while (error && i >= 0);
	
	BOOL isLastPage = NO;
	
	if (!error) {
		NSLog(@"%@", responseObject);
		NSDictionary * dataDic = responseObject[@"data"];
		
		NSNumber * lastPageNum = dataDic[@"isLastPage"];
		
		if (!QJ_IS_NUM_NIL(lastPageNum))
			isLastPage = lastPageNum.boolValue;
			
		NSArray * dataArray = dataDic[@"list"];
		
		__block NSMutableArray * resultArray = [[NSMutableArray alloc] init];
		[dataArray enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * stop) {
			[resultArray addObject:[[QJUser alloc] initWithJson:obj]];
		}];
		
		if (finished)
			finished(resultArray, isLastPage, dataArray, error);
		return;
	}
	
	if (finished)
		finished(nil, isLastPage, nil, error);
}

- (void)requestUserFollowMeList:(nullable NSNumber *)userId
	pageNum:(NSUInteger)pageNum
	pageSize:(NSUInteger)pageSize
	finished:(nullable void (^)(NSArray * followUserArray, BOOL isLastPage, NSArray * resultArray, NSError * error))finished
{
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	
	if (!QJ_IS_NUM_NIL(userId))
		params[@"userId"] = userId;
		
	if (pageNum == 0)
		pageNum = 1;
	params[@"pageNum"] = [NSNumber numberWithUnsignedInteger:pageNum];
	
	if (pageSize > 0)
		params[@"pageSize"] = [NSNumber numberWithUnsignedInteger:pageSize];
		
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJUserFollowMeListPath
		parameters:params
		success:^(AFHTTPRequestOperation * operation, id resultResponseObject) {
			NSLog(@"%@", operation.request.URL);
			responseObject = resultResponseObject;
			dispatch_semaphore_signal(sem);
		}
		failure:^(AFHTTPRequestOperation * operation, NSError * resultError) {
			NSLog(@"%@", operation.request.URL);
			error = resultError;
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		
		if (!error)
			error = [QJUtils errorFromOperation:responseObject];
		i--;
	} while (error && i >= 0);
	
	BOOL isLastPage = NO;
	
	if (!error) {
		NSLog(@"%@", responseObject);
		NSDictionary * dataDic = responseObject[@"data"];
		
		NSNumber * lastPageNum = dataDic[@"isLastPage"];
		
		if (!QJ_IS_NUM_NIL(lastPageNum))
			isLastPage = lastPageNum.boolValue;
			
		NSArray * dataArray = dataDic[@"list"];
		
		__block NSMutableArray * resultArray = [[NSMutableArray alloc] init];
		[dataArray enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * stop) {
			[resultArray addObject:[[QJUser alloc] initWithJson:obj]];
		}];
		
		if (finished)
			finished(resultArray, isLastPage, dataArray, error);
		return;
	}
	
	if (finished)
		finished(nil, isLastPage, nil, error);
}

// 用户关注
- (NSError *)requestUserFollowUser:(NSNumber *)userId
{
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	
	if (!QJ_IS_NUM_NIL(userId))
		params[@"userId"] = userId;
		
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJUserFollowUserPath
		parameters:params
		success:^(AFHTTPRequestOperation * operation, id resultResponseObject) {
			NSLog(@"%@", operation.request.URL);
			responseObject = resultResponseObject;
			dispatch_semaphore_signal(sem);
		}
		failure:^(AFHTTPRequestOperation * operation, NSError * resultError) {
			NSLog(@"%@", operation.request.URL);
			error = resultError;
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		
		if (!error)
			error = [QJUtils errorFromOperation:responseObject];
		i--;
	} while (error && i >= 0);
	
	if (!error)
		NSLog(@"%@", responseObject);
		
	return error;
}

// 用户取消关注
- (NSError *)requestUserCancelFollowUser:(NSNumber *)userId
{
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	
	if (!QJ_IS_NUM_NIL(userId))
		params[@"userId"] = userId;
		
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJUserCancelFollowUserPath
		parameters:params
		success:^(AFHTTPRequestOperation * operation, id resultResponseObject) {
			NSLog(@"%@", operation.request.URL);
			responseObject = resultResponseObject;
			dispatch_semaphore_signal(sem);
		}
		failure:^(AFHTTPRequestOperation * operation, NSError * resultError) {
			NSLog(@"%@", operation.request.URL);
			error = resultError;
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		
		if (!error)
			error = [QJUtils errorFromOperation:responseObject];
		i--;
	} while (error && i >= 0);
	
	if (!error)
		NSLog(@"%@", responseObject);
		
	return error;
}

@end
