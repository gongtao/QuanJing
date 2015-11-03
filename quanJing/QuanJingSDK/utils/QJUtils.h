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

+ (NSString *)realImageUrlFromServerUrl:(NSString *)url;

+ (NSString *)stringFromJSONObject:(id)object error:(NSError * __autoreleasing *)error;

+ (id)jsonObjectFromString:(NSString *)jsonString error:(NSError * __autoreleasing *)error;

+ (NSString *)md5String:(NSString *)str;

@end

NS_ASSUME_NONNULL_END

#endif /* ifndef QJUtils_h */
