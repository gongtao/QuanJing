//
//  QJBaseManager.h
//  QuanJingSDK
//
//  Created by QJ on 15/11/2.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QJBaseManager : NSObject

- (NSError *)errorFromOperation:(id)operation;

- (BOOL)shouldRetryHttpRequest:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
