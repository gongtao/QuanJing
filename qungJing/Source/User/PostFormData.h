//
//  PostFormData.h
//  Weitu
//
//  Created by denghs on 15/7/17.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostFormData : NSObject

+(NSData*)bulidPostFormData:(id <NSObject>)value forKey:(NSString *)key;
@end
