//
//  QJCoreMacros.h
//  QuanJingSDK
//
//  Created by QJ on 15/10/19.
//  Copyright © 2015年 QJ. All rights reserved.
//

#ifndef QJCoreMacros_h
#define QJCoreMacros_h

//
// error domain
#define    QJServerErrorCodeDomain	@"com.quanjing.sdk.error.server"

#define    ERROR_REASON				@"reason"
#define    ERROR_DESCRIPTION		@"description"
#define    ERROR_RETRIABLE			@"retriable"

#define QJ_SET_SERVER_NSERROR(errorPtr, errorCode, errorInfoDic)			\
	if (errorPtr != NULL) {													\
		*errorPtr = [[NSError alloc] initWithDomain:QJServerErrorCodeDomain	\
			code:errorCode													\
			userInfo:errorInfoDic];											\
	}
	
#define QJ_INIT_SERVER_NSERROR(errorPtr, errorCode, errorInfoDic)	   \
	errorPtr = [[NSError alloc] initWithDomain:QJServerErrorCodeDomain \
		code:errorCode												   \
		userInfo:errorInfoDic];
		
#define QJ_INIT_NSERROR_USER_INFO(userInfoDict, reason, description)						   \
	do {																					   \
		userInfoDict = [[NSMutableDictionary alloc] initWithCapacity:0];					   \
		if (reason != nil) [userInfoDict setObject:reason forKey:ERROR_REASON];				   \
		if (description != nil) [userInfoDict setObject:description forKey:ERROR_DESCRIPTION]; \
	} while (false);
	
// 判断对象是否为空
#define QJ_IS_STR_NIL(objStr)		(![objStr isKindOfClass:[NSString class]] || objStr == nil || [objStr length] <= 0 || [objStr isEqualToString:@"<null>"])
#define QJ_IS_DICT_NIL(objDict)		(![objDict isKindOfClass:[NSDictionary class]] || objDict == nil || [objDict count] <= 0)
#define QJ_IS_ARRAY_NIL(objArray)	(![objArray isKindOfClass:[NSArray class]] || objArray == nil || [objArray count] <= 0)
#define QJ_IS_NUM_NIL(objNum)		(![objNum isKindOfClass:[NSNumber class]] || objNum == nil)
#define QJ_IS_DATA_NIL(objData)		(![objData isKindOfClass:[NSData class]] || objData == nil || [objData length] <= 0)
#define QJ_IS_SET_NIL(objData)		(![objData isKindOfClass:[NSSet class]] || objData == nil || [objData count] <= 0)

#endif	/* QJCoreMacros_h */
