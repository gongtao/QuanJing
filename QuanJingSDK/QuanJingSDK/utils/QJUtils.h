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

#import "AFNetworking.h"

NS_ASSUME_NONNULL_BEGIN

@interface QJUtils : NSObject

+ (NSString *)realImageUrlFromServerUrl:(NSString *)url;

+ (nullable NSError *)errorFromOperation:(AFHTTPRequestOperation *)operation;

///---------------------------------
/// @name NSString And JSON Object
///---------------------------------

+ (NSString *)stringFromJSONObject:(id)object error:(NSError * __autoreleasing *)error;

+ (id)jsonObjectFromString:(NSString *)jsonString error:(NSError * __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END

#endif	/* ifndef QJUtils_h */
