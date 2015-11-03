//
//  MPUDIDKeyChainUtil.h
//  MiPassportFoundation
//
//  Created by Gongtao on 15/4/16.
//  Copyright (c) 2015年 Xiaomi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Security/Security.h>

@interface QJUDIDKeyChainUtil : NSObject

+ (void)setKeyChainAccessGroup:(NSString *)group;

+ (NSString *)getUDIDFromKeyChain;

+ (BOOL)setUDIDToKeyChain:(NSString *)udid;

+ (BOOL)removeUDIDFromKeyChain;

+ (BOOL)updateUDIDInKeyChain:(NSString *)newUDID;

@end
