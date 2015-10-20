//
//  QJInterfaceManager.h
//  QuanJingSDK
//
//  Created by QJ on 15/10/18.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@interface QJInterfaceManager : NSObject

+ (instancetype)sharedManager;

// 图片格式URL转换
+ (NSString *)thumbnailUrlFromImageUrl:(NSString *)imageUrl size:(CGSize)size;

///-------------------
/// @name 全景数据接口
///-------------------

// 首页接口
- (NSDictionary *)resultDicFromHomeIndexResponseData:(nullable NSArray *)data;
- (void)requestHomeIndex:(nullable void (^)(NSDictionary * homeIndexDic, NSArray * resultArray, NSError * error))finished;

// 搜索
- (void)requestImageSearchKey:(NSString *)key
	pageNum:(NSUInteger)pageNum
	pageSize:(NSUInteger)pageSize
	finished:(nullable void (^)(NSArray * imageObjectArray, NSArray * resultArray, NSError * error))finished;
	
// 首页根分类
- (void)requestImageRootCategory:(nullable void (^)(NSArray * imageCategoryArray, NSArray * resultArray, NSError * error))finished;

// 圈子列表
- (NSArray *)resultDicFromActionListResponseData:(nullable NSArray *)data;
- (void)requestActionList:(nullable NSNumber *)cursorIndex
	pageSize:(NSUInteger)pageSize
	userId:(nullable NSNumber *)userId
	finished:(nullable void (^)(NSArray * actionArray, NSArray * resultArray, NSNumber * nextCursorIndex, NSError * error))finished;
	
@end

NS_ASSUME_NONNULL_END
