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

#import "QJServerConstants.h"

@implementation QJUtils

#pragma mark - URL

+ (NSString *)realImageUrlFromServerUrl:(NSString *)url
{
	if ([url hasPrefix:@"http://"] ||
		[url hasPrefix:@"https://"])
		return [url stringByReplacingOccurrencesOfString:kQJFakePhotoServerHost
			   withString:kQJPhotoServerHost];
			   
	NSString * resultUrl = [NSString stringWithFormat:@"http://%@", kQJPhotoServerHost];
	return [resultUrl stringByAppendingString:url];
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
