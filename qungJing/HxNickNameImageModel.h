//
//  HxNickNameImageModel.h
//  Weitu
//
//  Created by denghs on 15/5/26.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HxNickNameImageModel : NSObject

+(void)askProfileNickNamebyUserIds:(NSArray*)usrId;

+(NSMutableArray*)getAvatarNickNameArray:(NSArray*)usrId;

+(NSMutableArray*)getAvatarNickNameRequest:(NSArray*)userArray;

+(NSString*)getNickName:(NSString*)userId;

+(UIImage*)getProfileImage:(NSString*)userId;

+(UIImage*)getProfileImageWithoutPrefix:(NSString*)userId;

+(void)synDeleChatData:(NSString *)userId;

+(void)getProfileByavatarUrl:(NSArray*)userArray;
@end
