//
//  NSString+ContentCheck.m
//  Weitu
//
//  Created by Su on 3/29/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "NSString+ContentCheck.h"

@implementation NSString (ContentCheck)

- (BOOL)isValidChineseCellphoneNumberWithoutPrefix
{
    return [self matchesRegexPatternExactly:@"^(1[34578][0-9])\\d{8}$"];
}

- (BOOL)isValidEmailAddress
{
    return [self matchesRegexPatternExactly:@"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$"];
}

- (BOOL)isValidNumberOfDigitNum:(NSInteger)digitNum
{
    return ([self matchesRegexPatternExactly:@"^[0-9]*$"]) && (self.length == digitNum);
}

- (BOOL)matchesRegexPatternExactly:(NSString*)regexPattern
{
	NSError* error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexPattern
                                                                           options:0
                                                                             error:&error];
    if (regex != nil)
    {
        NSAssert(error == nil, @"");
        NSTextCheckingResult *firstMatch= [regex firstMatchInString:self
                                                            options:0
                                                              range:NSMakeRange(0, self.length)];
        
        if (firstMatch)
        {
            return YES;
        }
    }

    return NO;
}

@end
