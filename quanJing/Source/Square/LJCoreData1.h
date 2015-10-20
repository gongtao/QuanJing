//
//  LJCoreData1.h
//  Weitu
//
//  Created by qj-app on 15/6/25.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LJHuancunModel.h"
@interface LJCoreData1 : NSObject
+(id)shareInstance;
-(void)insert:(NSData *)response withType:(NSString *)type withUserId:(NSString *)userid;
-(LJHuancunModel *)check:(NSString *)type withUserid:(NSString *)userid;
-(void)deleteImage:(NSString *)type;
-(void)update:(NSString *)type with:(NSData *)response withUserid:(NSString *)userid;
-(void)deleteAll;
@end
