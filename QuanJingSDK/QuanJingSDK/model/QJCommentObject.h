//
//  QJCommentObject.h
//  QuanJingSDK
//
//  Created by QJ on 15/10/20.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import "QJUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface QJCommentObject : NSObject

@property (nonatomic, strong, nullable) QJUser * user;

@property (nonatomic, strong, nullable) NSString * comment;

@property (nonatomic, strong, nullable) NSDate * time;

- (instancetype)initWithJson:(nullable NSDictionary *)json;

@end

NS_ASSUME_NONNULL_END
