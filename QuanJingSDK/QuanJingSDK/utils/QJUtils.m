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

#import <CommonCrypto/CommonDigest.h>

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

#pragma mark - MD5

+ (NSString *)md5String:(NSString *)str
{
	if (QJ_IS_STR_NIL(str))
		return nil;
		
	const char * cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
	return [NSString stringWithFormat:
		   @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
		   result[0], result[1], result[2], result[3],
		   result[4], result[5], result[6], result[7],
		   result[8], result[9], result[10], result[11],
		   result[12], result[13], result[14], result[15]
	];
}

@end
