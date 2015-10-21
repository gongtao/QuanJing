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

#import "QJArticleCategory.h"

#import "QJArticleObject.h"

#import "QJServerConstants.h"

#import "QJCoreMacros.h"

#import "QJErrorCode.h"

#import "QJHTTPManager.h"

#import "QJUtils.h"

@interface QJInterfaceManager ()

- (AFHTTPRequestOperationManager *)httpRequestManager;

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
//	if ((size.width <= 0.0) || (size.height <= 0.0))
//		return imageUrl;
//
//	NSString * whStr = nil;
//	
//	if (size.width > size.height)
//		whStr = [NSString stringWithFormat:@"%luw", (NSUInteger)size.width];
//	else
//		whStr = [NSString stringWithFormat:@"%luh", (NSUInteger)size.height];
//	NSString * url = [imageUrl stringByAppendingString:@"@"];
//	return [url stringByAppendingString:whStr];
	
	return imageUrl;
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

#pragma mark - Private

#pragma mark - 首页

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
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		NSLog(@"homeIndex begin");
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJHomeIndexPath
			parameters:nil
			success:^(AFHTTPRequestOperation * operation, id responseObject) {
			NSLog(@"homeIndex success");
			dispatch_semaphore_signal(sem);
		}
			failure:^(AFHTTPRequestOperation * operation, NSError * error) {
			NSLog(@"homeIndex fail");
			dispatch_semaphore_signal(sem);
		}];
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
		NSLog(@"homeIndex end");
		error = [QJUtils errorFromOperation:operation];
		i--;
	} while (error && i >= 0);
	
	NSLog(@"%@", operation.request.URL);
	
	if (!error) {
		NSLog(@"%@", operation.responseObject);
		NSArray * dataArray = operation.responseObject[@"data"];
		
		if (finished)
			finished([self resultDicFromHomeIndexResponseData:dataArray], dataArray, error);
		return;
	}
	
	if (finished)
		finished(nil, nil, error);
}

#pragma mark - 搜索

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
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJSearchPath
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
		NSArray * dataArray = operation.responseObject[@"data"];
		
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

#pragma mark - 首页分类

- (void)requestImageRootCategory:(nullable void (^)(NSArray * imageCategoryArray, NSArray * resultArray, NSError * error))finished
{
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJImageCategoryPath
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
		NSArray * dataArray = operation.responseObject[@"data"];
		
		__block NSMutableArray * resultArray = [[NSMutableArray alloc] init];
		[dataArray enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * stop) {
			[resultArray addObject:[[QJImageCategory alloc] initWithJson:obj]];
		}];
		
		if (finished)
			finished(resultArray, dataArray, error);
		return;
	}
	
	if (finished)
		finished(nil, nil, error);
}

#pragma mark - 图片故事（发现）

- (void)requestArticleCategory:(nullable void (^)(NSArray * articleCategoryArray, NSArray * resultArray, NSError * error))finished
{
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJArticleCategoryPath
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
		NSArray * dataArray = dataDic[@"page"];
		
		__block NSMutableArray * resultArray = [[NSMutableArray alloc] init];
		[dataArray enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * stop) {
			[resultArray addObject:[[QJArticleCategory alloc] initWithJson:obj]];
		}];
		
		if (finished)
			finished(resultArray, dataArray, error);
		return;
	}
	
	if (finished)
		finished(nil, nil, error);
}

- (void)requestArticleList:(nullable NSNumber *)categoryId
	cursorIndex:(nullable NSNumber *)cursorIndex
	pageSize:(NSUInteger)pageSize
	finished:(nullable void (^)(NSArray * articleObjectArray, NSArray * resultArray, NSError * error))finished
{
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	
	if (!QJ_IS_NUM_NIL(categoryId))
		params[@"categoryId"] = categoryId;
		
	if (pageSize > 0)
		params[@"pageSize"] = [NSNumber numberWithUnsignedInteger:pageSize];
		
	if (!QJ_IS_NUM_NIL(cursorIndex))
		params[@"cursorIndex"] = cursorIndex;
		
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJArticleListPath
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
		NSArray * dataArray = operation.responseObject[@"data"];
		
		__block NSMutableArray * resultArray = [[NSMutableArray alloc] init];
        [dataArray enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * stop) {
            [resultArray addObject:[[QJImageCategory alloc] initWithJson:obj]];
        }];
		
		if (finished)
			finished(resultArray, dataArray, error);
		return;
	}
	
	if (finished)
		finished(nil, nil, error);
}

#pragma mark - 圈子

- (void)resultArrayFromActionListResponseData:(nullable NSArray *)data
	finished:(nullable void (^)(NSArray * actionArray, NSNumber * nextCursorIndex))finished
{
	__block NSNumber * nextCursorIndex = nil;
	__block NSMutableArray * resultArray = [[NSMutableArray alloc] init];
	
	[data enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * stop) {
		QJActionObject * actionObject = [[QJActionObject alloc] initWithJson:obj];
		[resultArray addObject:actionObject];
		
		if (idx == data.count - 1) {
			NSNumber * creatTime = obj[@"creatTime"];
			
			if (!QJ_IS_NUM_NIL(creatTime))
				nextCursorIndex = creatTime;
		}
	}];
	
	if (finished)
		finished(resultArray, nextCursorIndex);
}

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
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJActionListPath
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
		NSArray * dataArray = operation.responseObject[@"data"];
		
		[self resultArrayFromActionListResponseData:dataArray
		finished:^(NSArray * actionArray, NSNumber * nextCursorIndex) {
			if (finished)
				finished(actionArray, dataArray, nextCursorIndex, error);
		}];
		return;
	}
	
	if (finished)
		finished(nil, nil, nil, error);
}

- (NSError *)requestLikeAction:(NSNumber *)actionId
{
	NSParameterAssert(actionId);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	params[@"actionId"] = actionId;
	
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJLikeActionPath
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

- (NSError *)requestCancelLikeAction:(NSNumber *)actionId
{
	NSParameterAssert(actionId);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	params[@"actionId"] = actionId;
	
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJCancelLikeActionPath
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

- (NSError *)requestCollectAction:(NSNumber *)actionId
{
	NSParameterAssert(actionId);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	params[@"actionId"] = actionId;
	
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJCollectActionPath
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

- (NSError *)requestCommentAction:(NSNumber *)actionId comment:(NSString *)comment
{
	NSParameterAssert(actionId);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	params[@"actionId"] = actionId;
	params[@"content"] = comment;
	
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager POST:kQJCommentActionPath
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

@end
