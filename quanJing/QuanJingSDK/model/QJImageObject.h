//
//  QJImageObject.h
//  QuanJingSDK
//
//  Created by QJ on 15/10/19.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import "QJCommentObject.h"

#import "QJUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface QJImageObject : NSObject

@property (nonatomic, strong) NSNumber * imageId;

@property (nonatomic, strong, nullable) NSNumber * albumId;

@property (nonatomic, strong, nullable) NSNumber * width;

@property (nonatomic, strong, nullable) NSNumber * height;

@property (nonatomic, strong, nullable) NSString * tag;

@property (nonatomic, strong, nullable) NSString * title;

@property (nonatomic, strong) NSString * url;

@property (nonatomic, strong) NSNumber * userId;

@property (nonatomic, strong, nullable) NSString * bgcolor;

@property (nonatomic, strong, nullable) NSNumber * imageType;

@property (nonatomic, strong, nullable) NSNumber * authId;

@property (nonatomic, strong, nullable) NSString * brand;

@property (nonatomic, strong, nullable) NSString * captionCn;

@property (nonatomic, strong, nullable) NSString * captionEn;

@property (nonatomic, strong, nullable) NSNumber * categoryId;

@property (nonatomic, strong, nullable) NSArray * comments;

@property (nonatomic, strong, nullable) NSDate * creatTime;

@property (nonatomic, strong, nullable) NSString * descript;

@property (nonatomic, strong, nullable) NSNumber * downloadTimes;

@property (nonatomic, strong, nullable) NSString * hvsp;

@property (nonatomic, strong, nullable) NSArray * likes;

@property (nonatomic, strong, nullable) NSString * md5;

@property (nonatomic, strong, nullable) NSString * modelRelease;

@property (nonatomic, strong, nullable) NSString * permissions;

@property (nonatomic, strong, nullable) NSString * photographer;

@property (nonatomic, strong, nullable) NSNumber * picType;

@property (nonatomic, strong, nullable) NSDate * shootingDate;

@property (nonatomic, strong, nullable) NSString * source;

@property (nonatomic, strong, nullable) NSNumber * open;

@property (nonatomic, strong, nullable) NSString * position;

@property (nonatomic, strong, nullable) NSNumber * rank;

@property (nonatomic, strong, nullable) NSNumber * size;

- (instancetype)initWithJson:(nullable NSDictionary *)json;

@end

NS_ASSUME_NONNULL_END
