#pragma once

#ifdef __OBJC__
extern NSString* kWTErrorDomain;
#endif

typedef enum _EWTErrorCodes
{
    kWTErrorOK = 0,
    kWTErrorGeneral = 1,
    kWTErrorBadParam = 2,
    kWTErrorNotFound = 3,
    kWTErrorAuthFailed = 4,
    kWTErrorAuthFailedTimeout = 5,
    kWTErrorDuplicated = 6,
    kWTErrorNetwork = 7,
} EWTErrorCodes;