//
//  QJArticleCategory.h
//  QuanJingSDK
//
//  Created by QJ on 15/10/21.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QJArticleCategory : NSObject

@property (nonatomic, strong) NSNumber * cid;

@property (nonatomic, strong, nullable) NSString * name;

@property (nonatomic, strong, nullable) NSDate * creatTime;

- (instancetype)initWithJson:(nullable NSDictionary *)json;

@end

NS_ASSUME_NONNULL_END
