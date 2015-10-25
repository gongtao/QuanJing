//
//  QJAlbumObject.h
//  QuanJingSDK
//
//  Created by QJ on 15/10/25.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QJAlbumObject : NSObject

@property (nonatomic, strong) NSNumber * aid;

@property (nonatomic, strong, nullable) NSNumber * userId;

@property (nonatomic, strong, nullable) NSString * name;

@property (nonatomic, strong, nullable) NSDate * creatTime;

- (instancetype)initWithJson:(nullable NSDictionary *)json;

@end

NS_ASSUME_NONNULL_END
