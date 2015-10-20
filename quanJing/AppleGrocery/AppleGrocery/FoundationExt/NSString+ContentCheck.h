//
//  NSString+ContentCheck.h
//  Weitu
//
//  Created by Su on 3/29/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ContentCheck)

- (BOOL)isValidChineseCellphoneNumberWithoutPrefix;
- (BOOL)isValidEmailAddress;
- (BOOL)isValidNumberOfDigitNum:(NSInteger)digitNum;
- (BOOL)matchesRegexPatternExactly:(NSString*)regexPattern;

@end
