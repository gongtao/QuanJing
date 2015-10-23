//
//  QJUtils.m
//  QuanJingSDK
//
//  Created by QJ on 15/10/20.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import "QJUtils.h"

#import "QJCoreMacros.h"

#import "QJErrorCode.h"

@implementation QJUtils

+ (NSError *)errorFromOperation:(AFHTTPRequestOperation *)operation
{
	NSError * error = operation.error;
	
	if (error)
		return error;
		
	NSDictionary * dic = (NSDictionary *)operation.responseObject;
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

#pragma mark - JSON with NSString

+ (NSString *)stringFromJSONObject:(id)object error:(NSError * __autoreleasing *)error
{
	NSData * jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:error];
	
	if (error && *error)
		return nil;
		
	NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	return jsonString;
}

+ (id)jsonObjectFromString:(NSString *)jsonString error:(NSError * __autoreleasing *)error
{
	if (QJ_IS_STR_NIL(jsonString))
		return nil;
		
	NSData * data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
	id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:error];
	
	if (error && *error)
		return nil;
		
	return jsonObject;
}

@end
