//
//  QJInterfaceManager.m
//  QuanJingSDK
//
//  Created by QJ on 15/10/18.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import "QJInterfaceManager.h"

#import "QJHomeIndexObject.h"

#import "QJImageCategory.h"

#import "QJActionObject.h"

#import "QJArticleCategory.h"

#import "QJArticleObject.h"

#import "QJAlbumObject.h"

#import "QJServerConstants.h"

#import "QJCoreMacros.h"

#import "QJErrorCode.h"

#import "QJHTTPManager.h"

#import "QJUtils.h"

#import "QJPassport.h"

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
	if ((size.width <= 0.0) && (size.height <= 0.0))
		return imageUrl;
		
	if ([imageUrl rangeOfString:kQJPhotoServerHost].location == NSNotFound)
		return imageUrl;
		
	NSUInteger width = (NSUInteger)size.width * [[UIScreen mainScreen] scale];
	NSUInteger height = (NSUInteger)size.height * [[UIScreen mainScreen] scale];
	NSString * url = [imageUrl stringByAppendingString:@"@"];
	NSString * resultUrl = [url stringByAppendingString:[NSString stringWithFormat:@"%luw_%luh_100Q_1x_1o.jpg", width, height]];
	return resultUrl;
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

#pragma mark - 注销

- (void)logout
{
	[[QJPassport sharedPassport] logout];
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
		error = [self errorFromOperation:operation];
		i--;
	} while ([self shouldRetryHttpRequest:error] && i >= 0);
	
	NSLog(@"%@", operation.request.URL);
	
	if (!error) {
		NSLog(@"%@", operation.responseObject);
		NSArray * dataArray = operation.responseObject[@"data"];
		
		if (!QJ_IS_ARRAY_NIL(dataArray)) {
			if (finished)
				finished([self resultDicFromHomeIndexResponseData:dataArray], dataArray, error);
			return;
		}
	}
	
	NSLog(@"%@", error);
	
	if (finished)
		finished(nil, nil, error);
}

#pragma mark - 搜索

- (void)requestImageSearchKey:(NSString *)key
	pageNum:(NSUInteger)pageNum
	pageSize:(NSUInteger)pageSize
	currentImageId:(NSNumber *)imageId
	finished:(nullable void (^)(NSArray * imageObjectArray, NSArray * resultArray, NSError * error))finished
{
	NSParameterAssert(key);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	params[@"key"] = key;
	
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
		operation = [self.httpRequestManager GET:kQJSearchPath
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
				QJImageObject * imageObject = [[QJImageObject alloc] initWithJson:obj];
				
				if (!QJ_IS_NUM_NIL(imageId) && [imageId isEqualToNumber:imageObject.imageId])
					return;
					
				imageObject.imageType = [NSNumber numberWithInt:1];
				[resultArray addObject:imageObject];
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
				[resultArray addObject:[[QJImageCategory alloc] initWithJson:obj]];
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
				[resultArray addObject:[[QJArticleCategory alloc] initWithJson:obj]];
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

- (void)requestArticleList:(nullable NSNumber *)categoryId
	cursorIndex:(nullable NSNumber *)cursorIndex
	pageSize:(NSUInteger)pageSize
	finished:(nullable void (^)(NSArray * articleObjectArray, NSNumber * nextCursorIndex, NSArray * resultArray, NSError * error))finished
{
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	
	if (!QJ_IS_NUM_NIL(categoryId))
		params[@"categoryId"] = categoryId;
		
	if (pageSize > 0)
		params[@"pageSize"] = [NSNumber numberWithUnsignedInteger:pageSize];
		
	if (!QJ_IS_NUM_NIL(cursorIndex)) {
		params[@"cursorIndex"] = cursorIndex;
		params[@"direction"] = [NSNumber numberWithInt:2];
	}
	
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
		error = [self errorFromOperation:operation];
		i--;
	} while ([self shouldRetryHttpRequest:error] && i >= 0);
	
	NSLog(@"%@", operation.request.URL);
	
	if (!error) {
		NSLog(@"%@", operation.responseObject);
		NSDictionary * dataDic = operation.responseObject[@"data"];
		NSArray * dataArray = dataDic[@"page"];
		
		if (!QJ_IS_ARRAY_NIL(dataArray)) {
			__block NSNumber * nextCursorIndex = nil;
			__block NSMutableArray * resultArray = [[NSMutableArray alloc] init];
			[dataArray enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * stop) {
				QJArticleObject * articleObject = [[QJArticleObject alloc] initWithJson:obj];
				[resultArray addObject:articleObject];
				
				if (idx == dataArray.count - 1)
					nextCursorIndex = articleObject.aid;
			}];
			
			if (finished)
				finished(resultArray, nextCursorIndex, dataArray, error);
			return;
		}
	}
	
	NSLog(@"%@", error);
	
	if (finished)
		finished(nil, nil, nil, error);
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
	
	if (!QJ_IS_NUM_NIL(cursorIndex)) {
		params[@"cursorIndex"] = cursorIndex;
		params[@"direction"] = [NSNumber numberWithInt:2];
	}
	
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
		error = [self errorFromOperation:operation];
		i--;
	} while ([self shouldRetryHttpRequest:error] && i >= 0);
	
	NSLog(@"%@", operation.request.URL);
	
	if (!error) {
		NSLog(@"%@", operation.responseObject);
		NSArray * dataArray = operation.responseObject[@"data"];
		
		if (!QJ_IS_ARRAY_NIL(dataArray)) {
			[self resultArrayFromActionListResponseData:dataArray
			finished:^(NSArray * actionArray, NSNumber * nextCursorIndex) {
				if (finished)
					finished(actionArray, dataArray, nextCursorIndex, error);
			}];
			return;
		}
	}
	
	NSLog(@"%@", error);
	
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

- (NSError *)requestCollectCancelAction:(NSNumber *)actionId
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
		operation = [self.httpRequestManager GET:kQJCollectCancelActionPath
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

#pragma mark - 图片详情

- (void)requestImageDetail:(NSNumber *)imageId
	imageType:(NSNumber *)imageType
	finished:(nullable void (^)(QJImageObject * imageObject, NSError * error))finished
{
	NSParameterAssert(imageId);
	NSParameterAssert(imageType);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	
	if (!QJ_IS_NUM_NIL(imageId))
		params[@"imageId"] = imageId;
		
	if (!QJ_IS_NUM_NIL(imageType))
		params[@"imageType"] = imageType;
		
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJImageDetailPath
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
		QJImageObject * imageObject = [[QJImageObject alloc] initWithJson:data];
		
		if (finished)
			finished(imageObject, error);
		return;
	}
	
	NSLog(@"%@", error);
	
	if (finished)
		finished(nil, error);
}

// 图片评论
- (NSError *)requestImageComment:(NSNumber *)imageId
	imageType:(NSNumber *)imageType
	comment:(NSString *)comment
{
	NSParameterAssert(imageId);
	NSParameterAssert(imageType);
	NSParameterAssert(comment);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	params[@"imageId"] = imageId;
	params[@"imageType"] = imageType;
	params[@"content"] = comment;
	
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager POST:kQJImageCommentPath
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

// 图片喜欢
- (NSError *)requestImageLike:(NSNumber *)imageId imageType:(NSNumber *)imageType
{
	NSParameterAssert(imageId);
	NSParameterAssert(imageType);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	params[@"imageId"] = imageId;
	params[@"imageType"] = imageType;
	
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJImageLikePath
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

// 图片取消喜欢
- (NSError *)requestImageCancelLike:(NSNumber *)imageId imageType:(NSNumber *)imageType;
{
	NSParameterAssert(imageId);
	NSParameterAssert(imageType);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	params[@"imageId"] = imageId;
	params[@"imageType"] = imageType;
	
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJImageCancelLikePath
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

// 图片收藏
- (NSError *)requestImageCollect:(NSNumber *)imageId imageType:(NSNumber *)imageType
{
	NSParameterAssert(imageId);
	NSParameterAssert(imageType);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	params[@"imageId"] = imageId;
	params[@"imageType"] = imageType;
	
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJImageCollectPath
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

// 图片取消收藏
- (NSError *)requestImageCancelCollect:(NSNumber *)imageId imageType:(NSNumber *)imageType;
{
	NSParameterAssert(imageId);
	NSParameterAssert(imageType);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	params[@"imageId"] = imageId;
	params[@"imageType"] = imageType;
	
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJImageCancelCollectPath
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

// 图片添加一次下载
- (NSError *)requestImageAddDownload:(NSNumber *)imageId imageType:(NSNumber *)imageType;
{
	NSParameterAssert(imageId);
	NSParameterAssert(imageType);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	params[@"imageId"] = imageId;
	params[@"imageType"] = imageType;
	
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager GET:kQJImageAddDownloadPath
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

#pragma mark - 用户列表

- (void)requestUserImageList:(nullable NSNumber *)userId
	pageNum:(NSUInteger)pageNum
	pageSize:(NSUInteger)pageSize
	currentImageId:(nullable NSNumber *)imageId
	finished:(nullable void (^)(NSArray * imageObjectArray, BOOL isLastPage, NSArray * resultArray, NSError * error))finished
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
		operation = [self.httpRequestManager GET:kQJUserImageListPath
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
				QJImageObject * imageObject = [[QJImageObject alloc] initWithJson:obj];
				
				if (!QJ_IS_NUM_NIL(imageId) && [imageObject.imageId isEqualToNumber:imageId])
					return;
					
				imageObject.imageType = [NSNumber numberWithInt:2];
				[resultArray addObject:imageObject];
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

- (void)requestUserCollectImageList:(nullable NSNumber *)userId
	pageNum:(NSUInteger)pageNum
	pageSize:(NSUInteger)pageSize
	finished:(nullable void (^)(NSArray * imageObjectArray, BOOL isLastPage, NSArray * resultArray, NSError * error))finished
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
		operation = [self.httpRequestManager GET:kQJUserCollectListPath
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
				QJImageObject * imageObject = [[QJImageObject alloc] initWithJson:obj];
				
				// imageId
				NSNumber * imageId = obj[@"imageId"];
				
				if (!QJ_IS_NUM_NIL(imageId))
					imageObject.imageId = imageId;
					
				[resultArray addObject:imageObject];
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

- (void)requestUserCommentImageList:(NSUInteger)pageNum
	pageSize:(NSUInteger)pageSize
	finished:(nullable void (^)(NSArray * commentObjectArray, BOOL isLastPage, NSArray * resultArray, NSError * error))finished
{
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	
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
		operation = [self.httpRequestManager GET:kQJUserCommentImageListPath
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
				[resultArray addObject:[[QJImageObject alloc] initWithJson:obj]];
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

- (void)requestUserLikeImageList:(nullable NSNumber *)userId
	pageNum:(NSUInteger)pageNum
	pageSize:(NSUInteger)pageSize
	finished:(nullable void (^)(NSArray * imageObjectArray, BOOL isLastPage, NSArray * resultArray, NSError * error))finished
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
		operation = [self.httpRequestManager GET:kQJUserLikeImageListPath
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
				QJImageObject * imageObject = [[QJImageObject alloc] initWithJson:obj];
				
				// imageId
				NSNumber * imageId = obj[@"imageId"];
				
				if (!QJ_IS_NUM_NIL(imageId))
					imageObject.imageId = imageId;
					
				[resultArray addObject:imageObject];
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

// 关注用户的图片列表
- (void)requestUserFollowUserImageList:(NSNumber *)userId
	pageNum:(NSUInteger)pageNum
	pageSize:(NSUInteger)pageSize
	finished:(nullable void (^)(NSArray * imageObjectArray, BOOL isLastPage, NSArray * resultArray, NSError * error))finished
{
	NSParameterAssert(userId);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	
	if (!QJ_IS_NUM_NIL(userId))
		params[@"userFollowId"] = userId;
		
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
		operation = [self.httpRequestManager GET:kQJUserFollowUserImageListPath
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
				QJImageObject * imageObject = [[QJImageObject alloc] initWithJson:obj];
				imageObject.imageType = [NSNumber numberWithInt:2];
				[resultArray addObject:imageObject];
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

#pragma mark - 用户相册

- (void)requestUserAlbumList:(NSUInteger)pageNum
	pageSize:(NSUInteger)pageSize
	finished:(nullable void (^)(NSArray * albumObjectArray, BOOL isLastPage, NSArray * resultArray, NSError * error))finished
{
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	
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
		operation = [self.httpRequestManager GET:kQJUserAlbumListPath
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
				[resultArray addObject:[[QJAlbumObject alloc] initWithJson:obj]];
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

- (void)requestUserAlbumImageList:(NSNumber *)albumId
	pageNum:(NSUInteger)pageNum
	pageSize:(NSUInteger)pageSize
	finished:(nullable void (^)(NSArray * imageObjectArray, BOOL isLastPage, NSArray * resultArray, NSError * error))finished
{
	NSParameterAssert(albumId);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	
	if (!QJ_IS_NUM_NIL(albumId))
		params[@"id"] = albumId;
		
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
		operation = [self.httpRequestManager GET:kQJUserAlbumImageListPath
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
				QJImageObject * imageObject = [[QJImageObject alloc] initWithJson:obj];
				imageObject.imageType = [NSNumber numberWithInt:2];
				[resultArray addObject:imageObject];
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

#pragma mark - 用户上传图片

- (void)requestUserAvatarTempData:(NSData *)imageData
	extension:(nullable NSString *)extension
	finished:(nullable void (^)(NSString * imageUrl, NSDictionary * imageDic, NSError * error))finished
{
	[self requestImageTempData:imageData
	extension:extension
	finished:^(NSDictionary * imageDic, NSError * error) {
		if (finished)
			finished(imageDic[@"url"], imageDic, error);
	}];
}

- (void)requestImageTempData:(NSData *)imageData
	extension:(nullable NSString *)extension
	finished:(nullable void (^)(NSDictionary * imageDic, NSError * error))finished
{
	NSParameterAssert(imageData);
	
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager POST:kQJUserPostTempImagePath
			parameters:nil
			constructingBodyWithBlock:^(id < AFMultipartFormData > formData) {
			[formData appendPartWithFileData:imageData
			name:@"f1"
			fileName:[NSString stringWithFormat:@"upload1.%@", extension]
			mimeType:@"application/octet-stream"];
		}
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
			NSDictionary * data = [dataArray firstObject];
			
			if (finished)
				finished(data, error);
			return;
		}
	}
	
	NSLog(@"%@", error);
	
	if (finished)
		finished(nil, error);
}

- (void)requestPostAction:(NSArray *)imageInfoArray
	albumId:(NSNumber *)albumId
	title:(NSString *)title
	tag:(NSString *)tag
	position:(NSString *)position
	open:(BOOL)open
	finished:(nullable void (^)(NSArray * imageObjectArray, NSArray * resultArray, NSError * error))finished
{
	NSMutableDictionary * actionDic = [[NSMutableDictionary alloc] init];
	
	if (!QJ_IS_NUM_NIL(albumId))
		actionDic[@"albumId"] = albumId;
		
	if (!QJ_IS_STR_NIL(title))
		actionDic[@"title"] = title;
		
	if (!QJ_IS_STR_NIL(tag))
		actionDic[@"tag"] = tag;
		
	if (!QJ_IS_STR_NIL(position))
		actionDic[@"position"] = position;
	actionDic[@"open"] = [NSNumber numberWithInteger:open];
	
	NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:imageInfoArray.count];
	[imageInfoArray enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * stop) {
		NSMutableDictionary * dic = [obj mutableCopy];
		[dic addEntriesFromDictionary:actionDic];
		[array addObject:dic];
	}];
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	NSString * json = [QJUtils stringFromJSONObject:array error:nil];
	params[@"json"] = json;
	
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	NSError * error = nil;
	AFHTTPRequestOperation * operation = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		operation = [self.httpRequestManager POST:kQJUserPostActionPath
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
				QJImageObject * imageObject = [[QJImageObject alloc] initWithJson:obj];
				imageObject.imageType = [NSNumber numberWithInt:2];
				[resultArray addObject:imageObject];
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

@end
