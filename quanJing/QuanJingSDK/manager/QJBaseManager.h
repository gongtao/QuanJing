//
//  QJBaseManager.h
//  QuanJingSDK
//
//  Created by QJ on 15/11/2.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kCookieDictionaryKey		@"kCookieDictionaryKey"
#define kQJUserNotLoginNotification @"kQJUserNotLoginNotification"

NS_ASSUME_NONNULL_BEGIN

@interface QJBaseManager : NSObject

+ (void)loadURLCookie;

+ (void)saveURLCookie;

+ (void)setKeyChainAccessGroup:(nullable NSString *)group;

+ (NSString *)getDeviceID;

- (nullable NSError *)errorFromOperation:(NSDictionary *)responseObject;

- (BOOL)shouldRetryHttpRequest:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
