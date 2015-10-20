//
//  PostFormData.m
//  Weitu
//
//  Created by denghs on 15/7/17.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "PostFormData.h"
#import <Foundation/NSZone.h>
@implementation PostFormData

+(NSData*)bulidPostFormData:(id <NSObject>)value forKey:(NSString *)key
{
    
    NSMutableDictionary *keyValuePair = [NSMutableDictionary dictionaryWithCapacity:2];
    [keyValuePair setValue:key forKey:@"key"];
    [keyValuePair setValue:[value description] forKey:@"value"];
    
     NSString *dataString = [NSString stringWithFormat:@"%@=%@%@", [self encodeURL:[keyValuePair objectForKey:@"key"]], [self encodeURL:[keyValuePair objectForKey:@"value"]], @""];
    
    NSData *data = [dataString dataUsingEncoding:4];
    return data;
}

#pragma mark utilities
+ (NSString*)encodeURL:(NSString *)string
{
    NSString *newString = (__bridge_transfer NSString*)(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(4)));
    
    if (newString) {
        return newString;
    }
    return @"";
}

@end
