//
//  HXChatInitModel.m
//  Weitu
//
//  Created by denghs on 15/5/19.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "HXChatInitModel.h"
#import <CommonCrypto/CommonDigest.h>
#import "OWTAccessToken.h"
#import "OWTUserManager.h"
#import "QuanJingSDK.h"
static NSString* kWTStoreKeyAccessToken = @"WTAccessToken";
static NSString* kWTClientID = @"3ae125d6e9a009a6fcce3f081f4ce5ff";

@implementation HXChatInitModel

+ (NSArray*)getCountAndPWDbyMD5;
{
//    获取 当前用户的token
//    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
//    NSData* data = [defaults objectForKey:kWTStoreKeyAccessToken];
//    OWTAccessToken* accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    //本机当前登陆用户的userID
//    OWTUser *user=GetUserManager().currentUser;
    QJUser *user=[QJPassport sharedPassport].currentUser;
    
    NSString *huanxinCount = [@"qj" stringByAppendingString:user.uid.stringValue];
    
    const char *cStr = [user.uid.stringValue UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result);
    NSString *passWord =  [NSString stringWithFormat:
                @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                result[0], result[1], result[2], result[3],
                result[4], result[5], result[6], result[7],
                result[8], result[9], result[10], result[11],
                result[12], result[13], result[14], result[15]
                ];
    passWord = passWord.uppercaseString;
    return [NSArray arrayWithObjects:huanxinCount, passWord.uppercaseString,nil];
}

@end
