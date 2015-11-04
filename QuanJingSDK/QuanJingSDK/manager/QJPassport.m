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

- (instancetype)init
{
	self = [super init];
	
	if (self) {}
	return self;
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
		error = [self errorFromOperation:operation];
		i--;
	} while ([self shouldRetryHttpRequest:error] && i >= 0);
	
	NSLog(@"%@", operation.request.URL);
	
	if (!error)
		NSLog(@"%@", operation.responseObject);
	else
		NSLog(@"%@", error);
		
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
		error = [self errorFromOperation:operation];
		i--;
	} while ([self shouldRetryHttpRequest:error] && i >= 0);
	
	NSLog(@"%@", operation.request.URL);
	
	if (!error) {
		NSLog(@"%@", operation.responseObject);
		NSDictionary * data = operation.responseObject[@"data"];
		NSNumber * userId = data[@"userId"];
		
		if (!self.currentUser)
			self.currentUser = [[QJUser alloc] init];
		self.currentUser.uid = userId;
		
		[QJBaseManager saveURLCookie];
		
		if (finished)
			finished(userId, data[@"ticket"], error);
		return;
	}
	
	NSLog(@"%@", error);
	
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
		error = [self errorFromOperation:operation];
		i--;
	} while ([self shouldRetryHttpRequest:error] && i >= 0);
	
	NSLog(@"%@", operation.request.URL);
	
	if (!error) {
		NSLog(@"%@", operation.responseObject);
		NSDictionary * data = operation.responseObject[@"data"];
		NSNumber * userId = data[@"userId"];
		
		if (!self.currentUser)
			self.currentUser = [[QJUser alloc] init];
		self.currentUser.uid = userId;
		
		[QJBaseManager saveURLCookie];
		
		if (finished)
			finished(userId, data[@"ticket"], error);
		return;
	}
	
	NSLog(@"%@", error);
	
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
		error = [self errorFromOperation:operation];
		i--;
	} while ([self shouldRetryHttpRequest:error] && i >= 0);
	
	NSLog(@"%@", operation.request.URL);
	
	if (!error)
		NSLog(@"%@", operation.responseObject);
	else
		NSLog(@"%@", error);
		
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
		error = [self errorFromOperation:operation];
		i--;
	} while ([self shouldRetryHttpRequest:error] && i >= 0);
	
	NSLog(@"%@", operation.request.URL);
	
	if (!error) {
		NSLog(@"%@", operation.responseObject);
		NSDictionary * data = operation.responseObject[@"data"];
		NSNumber * userId = data[@"userId"];
		
		if (!self.currentUser)
			self.currentUser = [[QJUser alloc] init];
		self.currentUser.uid = userId;
		
		[QJBaseManager saveURLCookie];
		
		if (finished)
			finished(userId, data[@"ticket"], error);
		return;
	}
	
	NSLog(@"%@", error);
	
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
		error = [self errorFromOperation:operation];
		i--;
	} while ([self shouldRetryHttpRequest:error] && i >= 0);
	
	NSLog(@"%@", operation.request.URL);
	
	if (!error) {
		NSLog(@"%@", operation.responseObject);
		NSDictionary * dataDic = operation.responseObject[@"data"];
		
		if (self.currentUser)
			[self.currentUser setPropertiesFromJson:dataDic];
		else
			self.currentUser = [[QJUser alloc] initWithJson:dataDic];
			
		if (finished)
			finished(self.currentUser, dataDic, error);
		return;
	}
	
	NSLog(@"%@", error);
	
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
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:url
			parameters:nil
			success:^(AFHTTPRequestOperation * operation, id responseObject) {
			dispatch_semaphore_signal(sem);
		}
			failure:^(AFHTTPRequestOperation * operation, NSError * error) {
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		error = [self errorFromOperation:operation];
		i--;
	} while ([self shouldRetryHttpRequest:error] && i >= 0);
	
	NSLog(@"%@", operation.request.URL);
	
	if (!error) {
		NSLog(@"%@", operation.responseObject);
		NSDictionary * dataDic = operation.responseObject[@"data"];
		QJUser * user = [[QJUser alloc] initWithJson:dataDic];
		
		if (finished)
			finished(user, dataDic, error);
		return;
	}
	
	NSLog(@"%@", error);
	
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
	if (!QJ_IS_NUM_NIL(user.bornArea))
		params[@"bornArea"] = user.bornArea;
		
	// residence
	if (!QJ_IS_NUM_NIL(user.residence))
		params[@"residence"] = user.residence;
		
	// stayArea
	if (!QJ_IS_NUM_NIL(user.stayArea))
		params[@"stayArea"] = user.stayArea;
		
	// stayArea
	if (!QJ_IS_NUM_NIL(user.stayAreaAddress))
		params[@"stayAreaAddress"] = user.stayAreaAddress;
		
	// introduce
	if (!QJ_IS_STR_NIL(user.introduce))
		params[@"introduce"] = user.introduce;
		
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
		error = [self errorFromOperation:operation];
		i--;
	} while ([self shouldRetryHttpRequest:error] && i >= 0);
	
	NSLog(@"%@", operation.request.URL);
	
	if (!error) {
		NSLog(@"%@", operation.responseObject);
		NSDictionary * dataDic = operation.responseObject[@"data"];
		
		if (self.currentUser)
			[self.currentUser setPropertiesFromJson:dataDic];
		else
			self.currentUser = [[QJUser alloc] initWithJson:dataDic];
			
		if (finished)
			finished(self.currentUser, dataDic, error);
		return;
	}
	
	NSLog(@"%@", error);
	
	if (finished)
		finished(self.currentUser, nil, error);
}

#pragma mark - 用户关注

- (void)requestUserFollowList:(NSNumber *)userId
	pageNum:(NSUInteger)pageNum
	pageSize:(NSUInteger)pageSize
	finished:(nullable void (^)(NSArray * followUserArray, NSArray * resultArray, NSError * error))finished
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
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJUserFollowListPath
			parameters:params
			success:^(AFHTTPRequestOperation * operation, id responseObject) {
			dispatch_semaphore_signal(sem);
		}
			failure:^(AFHTTPRequestOperation * operation, NSError * error) {
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		error = [self errorFromOperation:operation];
		i--;
	} while ([self shouldRetryHttpRequest:error] && i >= 0);
	
	NSLog(@"%@", operation.request.URL);
	
	if (!error) {
		NSLog(@"%@", operation.responseObject);
		NSArray * dataArray = operation.responseObject[@"data"];
		
		if (!QJ_IS_ARRAY_NIL(dataArray)) {
			__block NSMutableArray * resultArray = [[NSMutableArray alloc] init];
			[dataArray enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * stop) {
				QJUser * user = [[QJUser alloc] initWithJson:obj];
				
				NSNumber * followId = obj[@"followId"];
				
				if (!QJ_IS_NUM_NIL(followId))
					user.uid = followId;
					
				NSString * followUrl = obj[@"followUrl"];
				
				if (!QJ_IS_STR_NIL(followUrl))
					user.avatar = [QJUtils realImageUrlFromServerUrl:followUrl];
					
				NSNumber * meFollowed = obj[@"meFollowed"];
				
				if (!QJ_IS_NUM_NIL(meFollowed))
					user.hasFollowUser = meFollowed;
					
				[resultArray addObject:user];
			}];
			
			if (finished)
				finished(resultArray, dataArray, error);
			return;
		}
	}
	
	NSLog(@"%@", error);
	
	if (finished)
		finished(nil, nil, error);
}

- (void)requestUserFollowMeList:(nullable NSNumber *)userId
	pageNum:(NSUInteger)pageNum
	pageSize:(NSUInteger)pageSize
	finished:(nullable void (^)(NSArray * followUserArray, BOOL isLastPage, NSArray * resultArray, NSError * error))finished
{
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	
	if (!QJ_IS_NUM_NIL(userId))
		params[@"followId"] = userId;
		
	if (pageNum == 0)
		pageNum = 1;
	params[@"pageNum"] = [NSNumber numberWithUnsignedInteger:pageNum];
	
	if (pageSize > 0)
		params[@"pageSize"] = [NSNumber numberWithUnsignedInteger:pageSize];
		
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJUserFollowMeListPath
			parameters:params
			success:^(AFHTTPRequestOperation * operation, id responseObject) {
			dispatch_semaphore_signal(sem);
		}
			failure:^(AFHTTPRequestOperation * operation, NSError * error) {
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		error = [self errorFromOperation:operation];
		i--;
	} while ([self shouldRetryHttpRequest:error] && i >= 0);
	
	NSLog(@"%@", operation.request.URL);
	
	BOOL isLastPage = NO;
	
	if (!error) {
		NSLog(@"%@", operation.responseObject);
		NSDictionary * dataDic = operation.responseObject[@"data"];
		
		NSNumber * lastPageNum = dataDic[@"isLastPage"];
		
		if (!QJ_IS_NUM_NIL(lastPageNum))
			isLastPage = lastPageNum.boolValue;
			
		NSArray * dataArray = dataDic[@"list"];
		
		if (!QJ_IS_ARRAY_NIL(dataArray)) {
			__block NSMutableArray * resultArray = [[NSMutableArray alloc] init];
			[dataArray enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * stop) {
				QJUser * user = [[QJUser alloc] initWithJson:obj];
				
				NSNumber * userId = obj[@"userId"];
				
				if (!QJ_IS_NUM_NIL(userId))
					user.uid = userId;
					
				NSString * userUrl = obj[@"userUrl"];
				
				if (!QJ_IS_STR_NIL(userUrl))
					user.avatar = [QJUtils realImageUrlFromServerUrl:userUrl];
					
				// meFollowed
				NSNumber * meFollowed = obj[@"meFollowed"];
				
				if (!QJ_IS_NUM_NIL(meFollowed))
					user.hasFollowUser = meFollowed;
					
				[resultArray addObject:user];
			}];
			
			if (finished)
				finished(resultArray, isLastPage, dataArray, error);
			return;
		}
	}
	
	NSLog(@"%@", error);
	
	if (finished)
		finished(nil, isLastPage, nil, error);
}

- (void)requestUserFriendList:(NSNumber *)userId
	finished:(nullable void (^)(NSArray * userArray, NSError * error))finished
{
	__block NSError * resultError = nil;
	__block NSMutableSet * friendSet = [[NSMutableSet alloc] init];
	__block NSMutableArray * friends = [[NSMutableArray alloc] init];
	
	NSUInteger page = 1;
	
	[self requestUserFollowList:userId
	pageNum:page
	pageSize:50
	finished:^(NSArray * followUserArray, NSArray * resultArray, NSError * error) {
		if (error) {
			resultError = error;
			return;
		}
		[followUserArray enumerateObjectsUsingBlock:^(QJUser * obj, NSUInteger idx, BOOL * stop) {
			if (obj && ![friendSet containsObject:obj.uid]) {
				[friendSet addObject:obj.uid];
				[friends addObject:obj];
			}
		}];
	}];
	
	if (resultError) {
		if (finished)
			finished(friends, resultError);
		return;
	}
	
	__block BOOL isFinished = NO;
	
	for (page = 1; !resultError && !isFinished; page++) {
		[self requestUserFollowMeList:userId
		pageNum:page
		pageSize:50
		finished:^(NSArray * followUserArray, BOOL isLastPage, NSArray * resultArray, NSError * error) {
			if (error) {
				resultError = error;
				isFinished = YES;
				return;
			}
			[followUserArray enumerateObjectsUsingBlock:^(QJUser * obj, NSUInteger idx, BOOL * stop) {
				if (obj && ![friendSet containsObject:obj.uid]) {
					[friendSet addObject:obj.uid];
					[friends addObject:obj];
				}
            }];
            if (isLastPage) {
                isFinished = YES;
            }
		}];
	}
	
	if (finished)
		finished(friends, resultError);
}

// 用户关注
- (NSError *)requestUserFollowUser:(NSNumber *)userId
{
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	
	if (!QJ_IS_NUM_NIL(userId))
		params[@"userId"] = userId;
		
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJUserFollowUserPath
			parameters:params
			success:^(AFHTTPRequestOperation * operation, id responseObject) {
			dispatch_semaphore_signal(sem);
		}
			failure:^(AFHTTPRequestOperation * operation, NSError * error) {
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		error = [self errorFromOperation:operation];
		i--;
	} while ([self shouldRetryHttpRequest:error] && i >= 0);
	
	NSLog(@"%@", operation.request.URL);
	
	if (!error)
		NSLog(@"%@", operation.responseObject);
	else
		NSLog(@"%@", error);
		
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
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJUserCancelFollowUserPath
			parameters:params
			success:^(AFHTTPRequestOperation * operation, id responseObject) {
			dispatch_semaphore_signal(sem);
		}
			failure:^(AFHTTPRequestOperation * operation, NSError * error) {
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		error = [self errorFromOperation:operation];
		i--;
	} while ([self shouldRetryHttpRequest:error] && i >= 0);
	
	NSLog(@"%@", operation.request.URL);
	
	if (!error)
		NSLog(@"%@", operation.responseObject);
	else
		NSLog(@"%@", error);
		
	return error;
}

@end
