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
	
	if (finished)
		finished(nil, nil, error);
}

#pragma mark - 首页根分类

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
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJArticleCategoryPath
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
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJArticleListPath
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
		NSDictionary * dataDic = responseObject[@"data"];
		NSArray * dataArray = dataDic[@"page"];
		
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
			NSNumber * aid = actionObject.aid;
			
			if (!QJ_IS_NUM_NIL(aid))
				nextCursorIndex = aid;
		}
	}];
	
	if (finished)
		finished(resultArray, nextCursorIndex);
}

// 圈子列表
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
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJLikeActionPath
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
	
	if (!error)
		NSLog(@"%@", responseObject);
		
	return error;
}

- (NSError *)requestCancelLikeAction:(NSNumber *)actionId
{
	NSParameterAssert(actionId);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	params[@"actionId"] = actionId;
	
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJCancelLikeActionPath
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
	
	if (!error)
		NSLog(@"%@", responseObject);
		
	return error;
}

- (NSError *)requestCollectAction:(NSNumber *)actionId
{
	NSParameterAssert(actionId);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	params[@"actionId"] = actionId;
	
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJCollectActionPath
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
	
	if (!error)
		NSLog(@"%@", responseObject);
		
	return error;
}

- (NSError *)requestCollectCancelAction:(NSNumber *)actionId
{
	NSParameterAssert(actionId);
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	params[@"actionId"] = actionId;
	
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJCollectCancelActionPath
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
	
	if (!error)
		NSLog(@"%@", responseObject);
		
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
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager postPath:kQJCommentActionPath
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
	
	if (!error)
		NSLog(@"%@", responseObject);
		
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
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJImageDetailPath
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
		NSDictionary * data = responseObject[@"data"];
		QJImageObject * imageObject = [[QJImageObject alloc] initWithJson:data];
		
		if (finished)
			finished(imageObject, error);
		return;
	}
	
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
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager postPath:kQJImageCommentPath
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
	
	if (!error)
		NSLog(@"%@", responseObject);
		
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
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJImageLikePath
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
	
	if (!error)
		NSLog(@"%@", responseObject);
		
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
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJImageCancelLikePath
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
	
	if (!error)
		NSLog(@"%@", responseObject);
		
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
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJImageCollectPath
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
	
	if (!error)
		NSLog(@"%@", responseObject);
		
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
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJImageCancelCollectPath
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
	
	if (!error)
		NSLog(@"%@", responseObject);
		
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
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJImageAddDownloadPath
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
	
	if (!error)
		NSLog(@"%@", responseObject);
		
	return error;
}

#pragma mark - 用户列表

- (void)requestUserCollectImageList:(NSUInteger)pageNum
	pageSize:(NSUInteger)pageSize
	finished:(nullable void (^)(NSArray * imageObjectArray, BOOL isLastPage, NSArray * resultArray, NSError * error))finished
{
	NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
	
	if (pageNum == 0)
		pageNum = 1;
	params[@"pageNum"] = [NSNumber numberWithUnsignedInteger:pageNum];
	
	if (pageSize > 0)
		params[@"pageSize"] = [NSNumber numberWithUnsignedInteger:pageSize];
		
	// When request fails, if it could, retry it 3 times at most.
	int i = 3;
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJUserCollectListPath
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
	
	BOOL isLastPage = NO;
	
	if (!error) {
		NSLog(@"%@", responseObject);
		NSDictionary * dataDic = responseObject[@"data"];
		
		NSNumber * lastPageNum = dataDic[@"isLastPage"];
		
		if (!QJ_IS_NUM_NIL(lastPageNum))
			isLastPage = lastPageNum.boolValue;
			
		NSArray * dataArray = dataDic[@"list"];
		
		__block NSMutableArray * resultArray = [[NSMutableArray alloc] init];
		[dataArray enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * stop) {
			[resultArray addObject:[[QJImageObject alloc] initWithJson:obj]];
		}];
		
		if (finished)
			finished(resultArray, isLastPage, dataArray, error);
		return;
	}
	
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
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJUserCommentImageListPath
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
	
	BOOL isLastPage = NO;
	
	if (!error) {
		NSLog(@"%@", responseObject);
		NSDictionary * dataDic = responseObject[@"data"];
		
		NSNumber * lastPageNum = dataDic[@"isLastPage"];
		
		if (!QJ_IS_NUM_NIL(lastPageNum))
			isLastPage = lastPageNum.boolValue;
			
		NSArray * dataArray = dataDic[@"list"];
		
		__block NSMutableArray * resultArray = [[NSMutableArray alloc] init];
		[dataArray enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * stop) {
			[resultArray addObject:[[QJImageObject alloc] initWithJson:obj]];
		}];
		
		if (finished)
			finished(resultArray, isLastPage, dataArray, error);
		return;
	}
	
	if (finished)
		finished(nil, isLastPage, nil, error);
}

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
	__block NSError * error = nil;
	__block NSDictionary * responseObject = nil;
	
	do {
		error = nil;
		dispatch_semaphore_t sem = dispatch_semaphore_create(0);
		[self.httpRequestManager getPath:kQJUserAlbumListPath
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
	
	BOOL isLastPage = NO;
	
	if (!error) {
		NSLog(@"%@", responseObject);
		NSDictionary * dataDic = responseObject[@"data"];
		
		NSNumber * lastPageNum = dataDic[@"isLastPage"];
		
		if (!QJ_IS_NUM_NIL(lastPageNum))
			isLastPage = lastPageNum.boolValue;
			
		NSArray * dataArray = dataDic[@"list"];
		
		__block NSMutableArray * resultArray = [[NSMutableArray alloc] init];
		[dataArray enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * stop) {
			[resultArray addObject:[[QJAlbumObject alloc] initWithJson:obj]];
		}];
		
		if (finished)
			finished(resultArray, isLastPage, dataArray, error);
		return;
	}
	
	if (finished)
		finished(nil, isLastPage, nil, error);
}

@end
