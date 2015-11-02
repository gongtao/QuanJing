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

@interface QJBaseManager ()

- (AFHTTPClient *)httpRequestManager;

@end

@implementation QJBaseManager

#pragma mark - Property

- (AFHTTPClient *)httpRequestManager
{
	return [[QJHTTPManager sharedManager] httpRequestManager];
}

#pragma mark - Error

- (NSError *)errorFromOperation:(NSDictionary *)responseObject
{
	if (QJ_IS_DICT_NIL(responseObject))
		return nil;
		
	NSError * error = nil;
	NSDictionary * dic = responseObject;
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
		result = YES;
		
	return result;
}

@end
