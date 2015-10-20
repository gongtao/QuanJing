//
//  LJCoreData.h
//  Weitu
//
//  Created by qj-app on 15/6/10.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LJCaptionModel.h"
@interface LJCoreData : NSObject
+(id)shareIntance;
-(void)insert:(NSString *)imageUrl withCaption:(NSString *)caption with:(NSString *)isSelfInsert;
-(LJCaptionModel *)check:(NSString *)imageUrl;
-(void)deleteImage:(NSString *)imageUrl;
-(void)update:(NSString *)str  with:(NSString*)caption;
-(NSArray *)checkAll;
-(NSArray *)checkSomeImageUrl:(NSArray *)someCaptions;
-(void)checkAllAndUpdate;
@end
