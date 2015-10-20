//
//  NetStatusMonitor.m
//  Weitu
//
//  Created by denghs on 15/7/3.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "NetStatusMonitor.h"
#import "Reachability.h"
@implementation NetStatusMonitor


/***
 * 此函数用来判断是否网络连接服务器正常
 * 需要导入Reachability类
 */
+(BOOL)isExistenceNetwork
{
    BOOL isExistenceNetwork = YES;
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];  // 测试服务器状态
    
    switch([reachability currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = FALSE;
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = TRUE;
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = TRUE;
            break;
    }
    return  isExistenceNetwork;
}

@end
