#pragma once

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

typedef enum
{
    EaseTypeDefault,
    EaseTypeLinear,
    EaseTypeEaseIn,
    EaseTypeEaseOut,
    EaseTypeEaseInOut,
    EaseTypeSineIn,
    EaseTypeSineOut,
    EaseTypeSineInOut,
    EaseTypeQuadIn,
    EaseTypeQuadOut,
    EaseTypeQuadInOut,
    EaseTypeCubicIn,
    EaseTypeCubicOut,
    EaseTypeCubicInOut,
    EaseTypeQuartIn,
    EaseTypeQuartOut,
    EaseTypeQuartInOut,
    EaseTypeQuintIn,
    EaseTypeQuintOut,
    EaseTypeQuintInOut,
    EaseTypeExpoIn,
    EaseTypeExpoOut,
    EaseTypeExpoInOut,
    EaseTypeCircIn,
    EaseTypeCircOut,
    EaseTypeCircInOut,
    EaseTypeBackIn,
    EaseTypeBackOut,
    EaseTypeBackInOut   
} EaseType;


@interface OTimingFunctionFactory : NSObject
{
    
}

+(CAMediaTimingFunction *)functionWithType:(EaseType)type;

@end
