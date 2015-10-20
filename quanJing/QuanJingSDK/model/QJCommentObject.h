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

@property (nonatomic, strong) QJUser * user;

@property (nonatomic, strong) NSString * comment;

@property (nonatomic, strong) NSDate * time;

- (instancetype)initWithJson:(nullable NSDictionary *)json;

@end

NS_ASSUME_NONNULL_END
