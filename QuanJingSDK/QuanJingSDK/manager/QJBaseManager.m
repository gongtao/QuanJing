//
//  QJBaseManager.m
//  QuanJingSDK
//
//  Created by QJ on 15/11/2.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import "QJBaseManager.h"

#import "AFNetworking.h"

#import "QJCoreMacros.h"

#import "QJErrorCode.h"

@implementation QJBaseManager

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

@end
