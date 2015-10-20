//
//  SVProgressHUD+WTError.m
//  Weitu
//
//  Created by Su on 5/8/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "SVProgressHUD+WTError.h"
#import "OWTServerError.h"

@implementation SVProgressHUD (WTError)

+ (void)showError:(NSError*)error
{
    EWTErrorCodes code = (EWTErrorCodes)error.code;
    switch (code)
    {
        case kWTErrorAuthFailed:
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"EMAILAUTH_FAILED_CHECKINPUT", @"Login failed, please check your email and password.")];
            break;
        case kWTErrorDuplicated:
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"REGISTER_FAILED_DUPLICATE_EMAIL", @"Notify user email used.")];
            break;
        case kWTErrorNetwork:
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
            break;
        default:
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"GENERAL_ERROR_TRY_LATER", @"General error occurred, please try later.")];
            break;
    }
}

+ (void)showServerError:(OWTServerError *)error
{
    EWTErrorCodes code = (EWTErrorCodes)error.code;
    switch (code)
    {
        case kWTErrorNetwork:
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
            break;
        default:
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"GENERAL_ERROR_TRY_LATER", @"General error occurred, please try later.")];
            break;
    }
}

+ (void)showGeneralError
{
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"GENERAL_ERROR_TRY_LATER", @"General error occurred, please try later.")];
}

@end
