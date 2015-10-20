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
	QJServerErrorCodeUnknown = -1,							// "Unknown error"
} QJServerErrorCode;

#endif	/* QJErrorCode_h */
