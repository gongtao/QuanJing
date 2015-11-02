//
//  QJErrorCode.h
//  QuanJingSDK
//
//  Created by QJ on 15/10/19.
//  Copyright © 2015年 QJ. All rights reserved.
//

#ifndef QJErrorCode_h
#define QJErrorCode_h

#import <Foundation/Foundation.h>

// error domain
FOUNDATION_EXPORT NSString * const kQJServerErrorCodeDomain;

// error code
typedef enum {
	QJServerErrorCodeUnknown = -999,						// "Unknown error"
	QJServerErrorCodeNotLogin = -1,							// "Not Login"
	QJServerErrorCodeWrongTicket = -2,						// "Wrong ticket"
	QJServerErrorCodeNeedResetTicket = -3					// "Need reset ticket"
} QJServerErrorCode;

#endif	/* QJErrorCode_h */
