//
//  QJHomeIndexObject.h
//  QuanJingSDK
//
//  Created by QJ on 15/10/19.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QJHomeIndexObject : NSObject

@property (nonatomic, strong, nullable) NSDate * creatTime;

@property (nonatomic, strong, nonnull) NSString * imageUrl;

@property (nonatomic, strong, nullable) NSString * type;

@property (nonatomic, strong, nullable) NSString * typeValue;

@property (nonatomic, strong, nullable) NSString * position;

@property (nonatomic, strong, nullable) NSString * title;

@property (nonatomic, strong, nullable) NSString * detailText;

- (instancetype)initWithJson:(nullable NSDictionary *)json;

@end

NS_ASSUME_NONNULL_END
