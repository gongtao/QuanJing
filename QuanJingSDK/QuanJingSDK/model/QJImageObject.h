//
//  QJImageObject.h
//  QuanJingSDK
//
//  Created by QJ on 15/10/19.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QJImageObject : NSObject

@property (nonatomic, strong) NSNumber * imageId;

@property (nonatomic, strong, nullable) NSNumber * width;

@property (nonatomic, strong, nullable) NSNumber * height;

@property (nonatomic, strong, nullable) NSString * tag;

@property (nonatomic, strong) NSString * url;

@property (nonatomic, strong) NSNumber * userId;

@property (nonatomic, strong, nullable) NSString * bgcolor;

- (instancetype)initWithJson:(nullable NSDictionary *)json;

@end

NS_ASSUME_NONNULL_END
