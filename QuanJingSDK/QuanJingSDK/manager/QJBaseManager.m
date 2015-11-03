//
//  QJBaseManager.m
//  QuanJingSDK
//
//  Created by QJ on 15/11/2.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import "QJBaseManager.h"

#import "QJCoreMacros.h"

#import "QJErrorCode.h"

#import "QJHTTPManager.h"

#import "QJServerConstants.h"

@interface QJBaseManager ()

- (AFHTTPRequestOperationManager *)httpRequestManager;

@end

@implementation QJBaseManager

#pragma mark - Static

+ (void)initialize
{
	if ([self class] == [QJBaseManager class])
		[QJBaseManager loadURLCookie];
}

+ (void)loadURLCookie
{
	NSMutableDictionary * cookieDic = [[NSUserDefaults standardUserDefaults] objectForKey:kCookieDictionaryKey];
	
	if (QJ_IS_DICT_NIL(cookieDic))
		return;
		
	NSHTTPCookie * cookie = [NSHTTPCookie cookieWithProperties:cookieDic];
	NSHTTPCookieStorage * cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	[cookieJar setCookie:cookie];
}

+ (void)saveURLCookie
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

#pragma mark - User

- (NSError *)requestRelogin
{
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJUserReloginPath
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
		NSDictionary * data = operation.responseObject[@"data"];
		
		[QJBaseManager saveURLCookie];
	}
	
	return error;
}

- (void)logout
{}

#pragma mark - Property

- (AFHTTPRequestOperationManager *)httpRequestManager
{
	return [[QJHTTPManager sharedManager] httpRequestManager];
}

#pragma mark - error

- (NSError *)errorFromOperation:(id)operation
{
	if (![operation isKindOfClass:[AFHTTPRequestOperation class]])
		return nil;
		
	AFHTTPRequestOperation * op = (AFHTTPRequestOperation *)operation;
	NSError * error = op.error;
	
	if (error)
		return error;
		
	NSDictionary * dic = (NSDictionary *)op.responseObject;
	NSNumber * success = dic[@"success"];
	
	if (QJ_IS_NUM_NIL(success)) {
		NSMutableDictionary * errorInfo = nil;
		QJ_INIT_NSERROR_USER_INFO(errorInfo, @"Unknown", @"Server Error")
		error = [NSError errorWithDomain:kQJServerErrorCodeDomain code:QJServerErrorCodeUnknown userInfo:errorInfo];
		return error;
	}
	
	if (!success.boolValue) {
		NSString * msg = dic[@"msg"];
		NSMutableDictionary * errorInfo = nil;
		QJ_INIT_NSERROR_USER_INFO(errorInfo, msg, @"Server Error")
		error = [NSError errorWithDomain:kQJServerErrorCodeDomain code:QJServerErrorCodeUnknown userInfo:errorInfo];
	}
	return error;
}

- (BOOL)shouldRetryHttpRequest:(nullable NSError *)error
{
	BOOL result = NO;
	
	if (!error)
		return result;
		
	if ([error.domain isEqualToString:NSURLErrorDomain])
		switch (error.code) {
			case NSURLErrorUnknown:
			case NSURLErrorHTTPTooManyRedirects:
			case NSURLErrorRedirectToNonExistentLocation:
			case NSURLErrorZeroByteResource:
			case NSURLErrorCannotDecodeRawData:
			case NSURLErrorCannotDecodeContentData:
			case NSURLErrorCannotParseResponse:
			case NSURLErrorFileDoesNotExist:
			case NSURLErrorNoPermissionsToReadFile:
			case NSURLErrorCallIsActive:
				{
					result = YES;
					break;
				}
				
			default:
				break;
		}
	else if ([error.domain isEqualToString:QJServerErrorCodeDomain])
		switch (error.code) {
			case QJServerErrorCodeNotLogin:
				{
					dispatch_sync(dispatch_get_main_queue(), ^{
					[[NSNotificationCenter defaultCenter] postNotificationName:kQJUserNotLoginNotification object:nil];
				});
					break;
				}
				
			case QJServerErrorCodeNeedResetTicket:
				{
					NSError * reloginError = [self requestRelogin];
					
					if (!reloginError)
						result = YES;
					break;
				}
				
			default:
				break;
		}
		
	return result;
}

@end
