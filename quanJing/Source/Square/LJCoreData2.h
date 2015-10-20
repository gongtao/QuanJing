//
//  LJCoreData2.h
//  Weitu
//
//  Created by qj-app on 15/7/7.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LJCaptions.h"
@interface LJCoreData2 : NSObject
+(id)shareIntance;
-(void)insert2:(NSString *)imageUrl withCaption:(NSString *)caption with:(NSString *)number withData:(NSData *)imageData;
-(BOOL)check2:(NSString *)caption;
-(void)deleteImage2:(NSString *)imageUrl;
-(void)update2:(NSData *)imageData  with:(NSString*)caption;
-(NSArray *)checkAll2;
-(void)updateNum:(NSString *)number with:(NSString *)caption;
@end
