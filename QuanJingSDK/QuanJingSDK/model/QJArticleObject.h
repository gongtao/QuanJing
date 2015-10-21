//
//  QJArticleObject.h
//  QuanJingSDK
//
//  Created by QJ on 15/10/21.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QJArticleObject : NSObject

@property (nonatomic, strong) NSNumber * aid;

@property (nonatomic, strong, nullable) NSString * title;

@property (nonatomic, strong, nullable) NSString * summary;

@property (nonatomic, strong, nullable) NSString * subtitle;

@property (nonatomic, strong, nullable) NSNumber * categoryId;

@property (nonatomic, strong, nullable) NSString * categoryName;

@property (nonatomic, strong, nullable) NSString * content;

@property (nonatomic, strong, nullable) NSNumber * coverId;

@property (nonatomic, strong, nullable) NSString * coverUrl;

@property (nonatomic, strong, nullable) NSDate * creatTime;

@property (nonatomic, strong, nullable) NSDate * updateTime;

- (instancetype)initWithJson:(nullable NSDictionary *)json;

@end

NS_ASSUME_NONNULL_END
