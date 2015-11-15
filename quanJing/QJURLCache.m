//
//  QJURLCache.m
//  Weitu
//
//  Created by QJ on 15/11/15.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "QJURLCache.h"

#import <CommonCrypto/CommonCrypto.h>

#import <SDWebImageManager.h>

@interface SDImageCache (QuanJing)

- (NSString *)diskCachePath;

@end

@implementation QJURLCache

#pragma mark - Cache String

- (NSString *)cacheDir
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

- (NSString *)httpHeaderCacheDir
{
	NSString * urlCacheDir = [[self cacheDir] stringByAppendingPathComponent:@"httpHeaderCacheDir"];
	
	return urlCacheDir;
}

- (NSString *)cachedFileNameForKey:(NSString *)key
{
	const char * str = [key UTF8String];
	
	if (str == NULL)
		str = "";
	unsigned char r[CC_MD5_DIGEST_LENGTH];
	CC_MD5(str, (CC_LONG)strlen(str), r);
	NSString * filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
		r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
		
	return filename;
}

#pragma mark - HTTP Header

- (NSDictionary *)headerFieldsWithURL:(NSString *)url
{
	// 提取缓存HTTP头
	NSString * fileName = [self cachedFileNameForKey:url];
	NSString * httpHeaderCacheDir = [self httpHeaderCacheDir];
	NSString * filePath = [httpHeaderCacheDir stringByAppendingPathComponent:fileName];
	
	NSFileManager * manager = [NSFileManager new];
	
	if ([manager fileExistsAtPath:filePath])
		return [NSDictionary dictionaryWithContentsOfFile:filePath];
		
	return nil;
}

- (BOOL)storeHeaderFieldsWithHTTPResponse:(NSHTTPURLResponse *)response
{
	// 缓存HTTP头
	NSString * url = response.URL.absoluteString;
	NSString * fileName = [self cachedFileNameForKey:url];
	NSString * httpHeaderCacheDir = [self httpHeaderCacheDir];
	
	NSFileManager * manager = [NSFileManager new];
	
	if (![manager fileExistsAtPath:httpHeaderCacheDir])
		[manager createDirectoryAtPath:httpHeaderCacheDir withIntermediateDirectories:NO attributes:nil error:nil];
	NSString * filePath = [httpHeaderCacheDir stringByAppendingPathComponent:fileName];
	return [response.allHeaderFields writeToFile:filePath atomically:YES];
}

#pragma mark - Cache Data

- (NSData *)cacheImageDataFromURL:(NSString *)url
{
	NSString * dir = [[SDImageCache sharedImageCache] diskCachePath];
	NSString * fileName = [self cachedFileNameForKey:url];
	NSString * filePath = [dir stringByAppendingPathComponent:fileName];
	
	NSFileManager * manager = [NSFileManager new];
	
	if ([manager fileExistsAtPath:filePath])
		return [NSData dataWithContentsOfFile:filePath];
		
	return nil;
}

#pragma mark - Override

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
	NSString * url = request.URL.absoluteString;
	
	if (![url hasPrefix:@"http"] &&
		![url hasPrefix:@"https"]) {
		NSLog(@"Not HTTP Request");
		return nil;
	}
	
	if (![[request.HTTPMethod uppercaseString] isEqualToString:@"GET"]) {
		NSLog(@"Not HTTP GET Method");
		return nil;
	}
	
	NSDictionary * httpHeaders = [self headerFieldsWithURL:url];
	
	if (httpHeaders) {
		NSString * contentType = httpHeaders[@"Content-Type"];
		
		if ([contentType hasPrefix:@"image/"]) {
			NSData * data = [self cacheImageDataFromURL:url];
			
			if (data) {
				NSURLResponse * urlResponse = [[NSURLResponse alloc] initWithURL:request.URL
					MIMEType:contentType
					expectedContentLength:data.length
					textEncodingName:nil];
				NSCachedURLResponse * response = [[NSCachedURLResponse alloc] initWithResponse:urlResponse
					data:data
					userInfo:nil
					storagePolicy:NSURLCacheStorageAllowedInMemoryOnly];
				return response;
			}
		}
	}
	
	return nil;
}

- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request
{
	if (!cachedResponse.response ||
		![cachedResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
		NSLog(@"Not HTTP Response");
		return;
	}
	NSHTTPURLResponse * response = (NSHTTPURLResponse *)cachedResponse.response;
	
	if (response.statusCode != 200) {
		NSLog(@"HTTP Error Code: %li", response.statusCode);
		return;
	}
	
	NSLog(@"HTTP Response Headers:\n %@", response.allHeaderFields);
	
	NSData * data = cachedResponse.data;
	
	if (!data)
		return;
		
	NSString * url = response.URL.absoluteString;
	NSString * contentType = response.allHeaderFields[@"Content-Type"];
	
	if ([contentType hasPrefix:@"image/"] &&
		[self storeHeaderFieldsWithHTTPResponse:response]) {
		// 使用SDWebImage缓存图片
		UIImage * image = [UIImage imageWithData:data];
		[[SDImageCache sharedImageCache] storeImage:image
		recalculateFromImage:NO
		imageData:data
		forKey:url
		toDisk:YES];
		return;
	}
}

@end
