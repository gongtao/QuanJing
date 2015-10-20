//
//  LJCoreData3.h
//  Weitu
//
//  Created by qj-app on 15/8/5.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LJCoreData3 : NSObject
+(id)shareIntance;
-(void)insertCaptionSimilar:(NSString*)word withDetail:(NSString *)Detail;
-(NSArray *)checkCaptionSimilar:(NSString *)word;
-(void)deleteAll;
@end
