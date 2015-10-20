//
//  SVProgressHUD+WTError.h
//  Weitu
//
//  Created by Su on 5/8/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "SVProgressHUD.h"

@class OWTServerError;

@interface SVProgressHUD (WTError)

+ (void)showError:(NSError*)error;
+ (void)showServerError:(OWTServerError *)error;
+ (void)showGeneralError;

@end
