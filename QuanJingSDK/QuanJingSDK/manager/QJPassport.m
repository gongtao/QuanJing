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

- (AFHTTPRequestOperationManager *)httpRequestManager
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
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJUserSendRegistSMSPath
			parameters:params
			success:^(AFHTTPRequestOperation * operation, id responseObject) {
			dispatch_semaphore_signal(sem);
		}
			failure:^(AFHTTPRequestOperation * operation, NSError * error) {
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		error = [QJUtils errorFromOperation:operation];
		i--;
	} while (error && i >= 0);
	
	NSLog(@"%@", operation.request.URL);
	
	if (!error)
		NSLog(@"%@", operation.responseObject);
		
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
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJUserRegisterPath
			parameters:params
			success:^(AFHTTPRequestOperation * operation, id responseObject) {
			dispatch_semaphore_signal(sem);
		}
			failure:^(AFHTTPRequestOperation * operation, NSError * error) {
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		error = [QJUtils errorFromOperation:operation];
		i--;
	} while (error && i >= 0);
	
	NSLog(@"%@", operation.request.URL);
	
	if (!error) {
		NSLog(@"%@", operation.responseObject);
		NSDictionary * dataDic = operation.responseObject[@"data"];
		QJUser * user = [[QJUser alloc] initWithJson:dataDic];
		
		if (finished)
			finished(user, dataDic, error);
		return;
	}
	
	if (finished)
		finished(nil, nil, error);
}

#pragma mark - 登录

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
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJUserLoginPath
			parameters:params
			success:^(AFHTTPRequestOperation * operation, id responseObject) {
			dispatch_semaphore_signal(sem);
		}
			failure:^(AFHTTPRequestOperation * operation, NSError * error) {
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		error = [QJUtils errorFromOperation:operation];
		i--;
	} while (error && i >= 0);
	
	NSLog(@"%@", operation.request.URL);
	
	if (!error) {
		NSLog(@"%@", operation.responseObject);
		NSDictionary * data = operation.responseObject[@"data"];
		NSNumber * userId = data[@"userId"];
        
        self.currentUser = [[QJUser alloc] init];
        self.currentUser.uid = userId;
        
		if (finished)
			finished(userId.integerValue, data[@"ticket"], error);
		return;
	}
    
    self.currentUser = nil;
	
	if (finished)
		finished(0, nil, error);
}

- (NSError *)sendLoginSMS:(NSString *)phoneNumber
{
	NSParameterAssert(phoneNumber);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	params[@"phoneNumber"] = phoneNumber;
	
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJUserSendLoginSMSPath
			parameters:params
			success:^(AFHTTPRequestOperation * operation, id responseObject) {
			dispatch_semaphore_signal(sem);
		}
			failure:^(AFHTTPRequestOperation * operation, NSError * error) {
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		error = [QJUtils errorFromOperation:operation];
		i--;
	} while (error && i >= 0);
	
	NSLog(@"%@", operation.request.URL);
	
	if (!error)
		NSLog(@"%@", operation.responseObject);
		
	return error;
}

// 短信登录
- (void)loginUser:(NSString *)phoneNumber
	code:(NSString *)code
	finished:(void (^)(NSInteger userId, NSString * ticket, NSError * error))finished
{
	NSParameterAssert(phoneNumber);
	NSParameterAssert(code);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	params[@"phoneNumber"] = phoneNumber;
	params[@"code"] = code;
	
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJUserLoginSMSPath
			parameters:params
			success:^(AFHTTPRequestOperation * operation, id responseObject) {
			dispatch_semaphore_signal(sem);
		}
			failure:^(AFHTTPRequestOperation * operation, NSError * error) {
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		error = [QJUtils errorFromOperation:operation];
		i--;
	} while (error && i >= 0);
	
	NSLog(@"%@", operation.request.URL);
	
	if (!error) {
		NSLog(@"%@", operation.responseObject);
		NSDictionary * data = operation.responseObject[@"data"];
        NSNumber * userId = data[@"userId"];
        
        self.currentUser = [[QJUser alloc] init];
        self.currentUser.uid = userId;
		
		if (finished)
			finished(userId.integerValue, data[@"ticket"], error);
		return;
	}
    
    self.currentUser = nil;
	
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
}

#pragma mark - 用户信息

- (void)requestUserInfo:(void (^)(QJUser * user, NSDictionary * userDic, NSError * error))finished
{
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJUserInfoPath
			parameters:nil
			success:^(AFHTTPRequestOperation * operation, id responseObject) {
			dispatch_semaphore_signal(sem);
		}
			failure:^(AFHTTPRequestOperation * operation, NSError * error) {
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		error = [QJUtils errorFromOperation:operation];
		i--;
	} while (error && i >= 0);
	
	NSLog(@"%@", operation.request.URL);
	
	if (!error) {
		NSLog(@"%@", operation.responseObject);
		NSDictionary * dataDic = operation.responseObject[@"data"];
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
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager POST:kQJUserInfoModifyPath
			parameters:params
			success:^(AFHTTPRequestOperation * operation, id responseObject) {
			dispatch_semaphore_signal(sem);
		}
			failure:^(AFHTTPRequestOperation * operation, NSError * error) {
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		error = [QJUtils errorFromOperation:operation];
		i--;
	} while (error && i >= 0);
	
	NSLog(@"%@", operation.request.URL);
	
	if (!error) {
		NSLog(@"%@", operation.responseObject);
		NSDictionary * dataDic = operation.responseObject[@"data"];
		QJUser * newUser = [[QJUser alloc] initWithJson:dataDic];
		
		if (finished)
			finished(newUser, dataDic, error);
		return;
	}
	
	if (finished)
		finished(nil, nil, error);
}

@end
