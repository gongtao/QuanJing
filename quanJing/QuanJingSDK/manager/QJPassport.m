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

#pragma mark - Property

- (AFHTTPClient *)httpRequestManager
{
	return [[QJHTTPManager sharedManager] httpRequestManager];
}

#pragma mark - QuanJing User

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
	finished:(void (^)(QJUser * user, NSDictionary * userDic, NSError * error))finished
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
		NSDictionary * dataDic = responseObject[@"data"];
		QJUser * user = [[QJUser alloc] initWithJson:dataDic];
		
		if (finished)
			finished(user, dataDic, error);
		return;
	}
	
	if (finished)
		finished(nil, nil, error);
}

// 登录
- (void)loginUser:(NSString *)userName
	password:(NSString *)password
	finished:(void (^)(NSInteger userId, NSString * ticket, NSError * error))finished
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
		
		if (finished)
			finished(userId.integerValue, data[@"ticket"], error);
		return;
	}
	
	if (finished)
		finished(0, nil, error);
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

- (void)logout
{
	NSURL * url = [NSURL URLWithString:kQJServerURL];
	NSHTTPCookieStorage * cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray * cookies = [cookieJar cookiesForURL:url];
	
	[cookies enumerateObjectsUsingBlock:^(NSHTTPCookie * cookie, NSUInteger idx, BOOL * stop) {
		[cookieJar deleteCookie:cookie];
	}];
}

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
		QJUser * user = [[QJUser alloc] initWithJson:dataDic];
		
		if (finished)
			finished(user, dataDic, error);
		return;
	}
	
	if (finished)
		finished(nil, nil, error);
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
		QJUser * newUser = [[QJUser alloc] initWithJson:dataDic];
		
		if (finished)
			finished(newUser, dataDic, error);
		return;
	}
	
	if (finished)
		finished(nil, nil, error);
}

@end