//
//  QJUtils.h
//  QuanJingSDK
//
//  Created by QJ on 15/10/20.
//  Copyright © 2015年 QJ. All rights reserved.
//

#ifndef QJUtils_h

#define QJUtils_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QJUtils : NSObject

+ (nullable NSError *)errorFromOperation:(NSDictionary *)responseObject;

@end

NS_ASSUME_NONNULL_END

#endif