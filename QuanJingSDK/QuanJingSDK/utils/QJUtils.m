//
//  QJUtils.m
//  QuanJingSDK
//
//  Created by QJ on 15/10/20.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import "QJUtils.h"

#import "QJCoreMacros.h"

#import "QJErrorCode.h"

@implementation QJUtils

+ (NSError *)errorFromOperation:(AFHTTPRequestOperation *)operation
{
    NSError * error = operation.error;
    
    if (error)
        return error;
    
    NSDictionary * dic = (NSDictionary *)operation.responseObject;
    NSNumber * success = dic[@"success"];
    
    if (QJ_IS_NUM_NIL(success)) {
        NSMutableDictionary * errorInfo = nil;
        QJ_INIT_NSERROR_USER_INFO(errorInfo, @"Unknown", @"Server Error")
        error = [NSError errorWithDomain:kQJServerErrorCodeDomain code:QJServerErrorCodeUnknown userInfo:errorInfo];
        return error;
    }
    
    if (!success.boolValue) {
        NSString * msg = dic[@"msg"];
        NSMutableDictionary * errorInfo = nil;
        QJ_INIT_NSERROR_USER_INFO(errorInfo, msg, @"Server Error")
        error = [NSError errorWithDomain:kQJServerErrorCodeDomain code:QJServerErrorCodeUnknown userInfo:errorInfo];
    }
    return error;
}

@end
