//
//  QJInterfaceManager.m
//  QuanJingSDK
//
//  Created by QJ on 15/10/18.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import "QJInterfaceManager.h"

#import "QJHomeIndexObject.h"

#import "QJImageObject.h"

#import "QJImageCategory.h"

#import "QJActionObject.h"

#import "QJServerConstants.h"

#import "QJCoreMacros.h"

#import "QJErrorCode.h"

#import "QJHTTPManager.h"

#import "QJUtils.h"

@interface QJInterfaceManager ()

- (AFHTTPClient *)httpRequestManager;

@end

@implementation QJInterfaceManager

+ (instancetype)sharedManager
{
	static QJInterfaceManager * sharedAdapter = nil;
	static dispatch_once_t t;
	
	dispatch_once(&t, ^{
		sharedAdapter = [[QJInterfaceManager alloc] init];
	});
	return sharedAdapter;
}

+ (NSString *)thumbnailUrlFromImageUrl:(NSString *)imageUrl size:(CGSize)size
{
	//    if (size.width <= 0.0 || size.height <= 0.0) {
	//        return imageUrl;
	//    }
	//
	//    NSUInteger width = (NSUInteger)size.width;
	//    NSUInteger height = (NSUInteger)size.height;
	//    NSString *url = [imageUrl stringByAppendingString:@"@"];
	//    return [url stringByAppendingString:[NSString stringWithFormat:@"%luw_%luh", width, height]];
	return imageUrl;
}

- (instancetype)init
{
	self = [super init];
	
	if (self) {}
	return self;
}

#pragma mark - Property

- (AFHTTPClient *)httpRequestManager
{
	return [[QJHTTPManager sharedManager] httpRequestManager];
}

#pragma mark - Private

#pragma mark - QuanJing Interface

- (NSDictionary *)resultDicFromHomeIndexResponseData:(NSArray *)data
{
	__block NSMutableArray * lbtArray = [[NSMutableArray alloc] init];
	__block NSMutableArray * mhrsArray = [[NSMutableArray alloc] init];
	__block NSMutableArray * shzmArray = [[NSMutableArray alloc] init];
	__block NSMutableDictionary * resultDic = [[NSMutableDictionary alloc] initWithObjects:@[lbtArray, mhrsArray, shzmArray]
		forKeys:@[@"lbt", @"mhrs", @"shzm"]];
		
	[data enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * stop) {
		NSString * position = obj[@"position"];
		
		if (QJ_IS_STR_NIL(position))
			return;
			
		NSMutableArray * array = resultDic[position];
		
		if (!array)
			return;
			
		[array addObject:[[QJHomeIndexObject alloc] initWithJson:obj]];
	}];
	return resultDic;
}

- (void)requestHomeIndex:(void (^)(NSDictionary * homeIndexDic, NSArray * resultArray, NSError * error))finished
{
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJHomeIndexPath
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
		NSArray * dataArray = responseObject[@"data"];
		
		if (finished)
			finished([self resultDicFromHomeIndexResponseData:dataArray], dataArray, error);
		return;
	}
	
	if (finished)
		finished(nil, nil, error);
}

- (void)requestImageSearchKey:(NSString *)key
	pageNum:(NSUInteger)pageNum
	pageSize:(NSUInteger)pageSize
	finished:(nullable void (^)(NSArray * imageObjectArray, NSArray * resultArray, NSError * error))finished
{
	NSParameterAssert(key);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	params[@"key"] = key;
	
	if (pageNum == 0)
		pageNum = 1;
	params[@"pageNum"] = [NSNumber numberWithUnsignedInteger:pageNum];
	params[@"pageSize"] = [NSNumber numberWithUnsignedInteger:pageSize];
	
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJSearchPath
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
		NSArray * dataArray = responseObject[@"data"];
		
		__block NSMutableArray * resultArray = [[NSMutableArray alloc] init];
		[dataArray enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * stop) {
			[resultArray addObject:[[QJImageObject alloc] initWithJson:obj]];
		}];
		
		if (finished)
			finished(resultArray, dataArray, error);
		return;
	}
	
	if (finished)
		finished(nil, nil, error);
}

- (void)requestImageRootCategory:(nullable void (^)(NSArray * imageCategoryArray, NSArray * resultArray, NSError * error))finished
{
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJImageCategoryPath
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
		NSArray * dataArray = responseObject[@"data"];
		
		__block NSMutableArray * resultArray = [[NSMutableArray alloc] init];
		[dataArray enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * stop) {
			[resultArray addObject:[[QJImageCategory alloc] initWithJson:obj]];
		}];
		
		if (finished)
			finished(nil, dataArray, error);
		return;
	}
	
	if (finished)
		finished(nil, nil, error);
}

// - (NSArray *)resultDicFromActionListResponseData:(nullable NSArray *)data {
//
// }

// 圈子列表
- (void)requestActionList:(nullable NSNumber *)cursorIndex
	pageSize:(NSUInteger)pageSize
	userId:(nullable NSNumber *)userId
	finished:(nullable void (^)(NSArray * actionArray, NSArray * resultArray, NSNumber * nextCursorIndex, NSError * error))finished
{
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	
	if (!QJ_IS_NUM_NIL(cursorIndex))
		params[@"cursorIndex"] = cursorIndex;
		
	if (pageSize > 0)
		params[@"pageSize"] = [NSNumber numberWithUnsignedInteger:pageSize];
		
	if (!QJ_IS_NUM_NIL(userId))
		params[@"userId"] = userId;
		
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJActionListPath
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
		NSArray * dataArray = responseObject[@"data"];
		
		__block NSNumber * nextCursorIndex = nil;
		__block NSMutableArray * resultArray = [[NSMutableArray alloc] init];
		[dataArray enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * stop) {
			QJActionObject * actionObject = [[QJActionObject alloc] initWithJson:obj];
			[resultArray addObject:actionObject];
			
			if (idx == dataArray.count - 1) {
				NSNumber * creatTime = obj[@"creatTime"];
				
				if (!QJ_IS_NUM_NIL(creatTime))
					nextCursorIndex = creatTime;
			}
		}];
		
		if (finished)
			finished(resultArray, dataArray, nextCursorIndex, error);
		return;
	}
	
	if (finished)
		finished(nil, nil, nil, error);
}

@end
