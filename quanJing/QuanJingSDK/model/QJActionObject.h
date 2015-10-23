//
//  QJActionObject.h
//  QuanJingSDK
//
//  Created by QJ on 15/10/20.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import "QJCommentObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface QJActionObject : NSObject

@property (nonatomic, strong) NSNumber * aid;

@property (nonatomic, strong, nullable) NSNumber * userId;

@property (nonatomic, strong, nullable) QJUser * user;

@property (nonatomic, strong, nullable) NSNumber * type;

@property (nonatomic, strong, nullable) NSArray * likes;

@property (nonatomic, strong, nullable) NSArray * comments;

@property (nonatomic, strong, nullable) NSArray * images;

@property (nonatomic, strong, nullable) NSDate * creatTime;

- (instancetype)initWithJson:(nullable NSDictionary *)json;

@end

NS_ASSUME_NONNULL_END
