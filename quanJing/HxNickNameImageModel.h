//
//  HxNickNameImageModel.h
//  Weitu
//
//  Created by denghs on 15/5/26.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QJUser.h"
@interface HxNickNameImageModel : NSObject


@property (nonatomic, strong) void (^finshRequest)(QJUser* userId);

+(void)askProfileNickNamebyUserIds:(NSArray*)usrId;

+(NSMutableArray*)getAvatarNickNameArray:(NSArray*)usrId;

+(NSMutableArray*)getAvatarNickNameRequest:(NSArray*)userArray;

+(NSString*)getNickName:(NSString*)userId;

+(UIImage*)getProfileImage:(NSString*)userId;

+(UIImage*)getProfileImageWithoutPrefix:(NSString*)userId;

+(void)synDeleChatData:(NSString *)userId;

+(void)getProfileByavatarUrl:(NSArray*)userArray;

+(NSMutableArray*)getTriggleValeByIDArray:(NSArray*)usrIds;

+(id)getTriggleValeByuserID:(NSString*)usrId;

+(QJUser*)checekisExsitByID2:(NSString*)userId;

-(void)checekisExsitByID:(NSString*)userId;


@end
