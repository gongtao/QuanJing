//
//  QJHTTPManager.h
//  QuanJingSDK
//
//  Created by QJ on 15/10/20.
//  Copyright © 2015年 QJ. All rights reserved.
//

#ifndef QJHTTPManager_h

#define QJHTTPManager_h

#import <Foundation/Foundation.h>

#import "AFNetworking.h"

@interface QJHTTPManager : NSObject

@property (readonly, nonatomic, strong) NSString * userAgent;

+ (instancetype)sharedManager;

- (AFHTTPRequestOperationManager *)httpRequestManager;

@end

#endif
