#import "OTimingFunctionFactory.h"

@implementation OTimingFunctionFactory

+(CAMediaTimingFunction *)functionWithType:(EaseType)type
{
    switch (type)
    {
        case EaseTypeDefault:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
            break;
        case EaseTypeLinear:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            break;
        
        case EaseTypeEaseIn:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            break;
        case EaseTypeEaseOut:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            break;
        case EaseTypeEaseInOut:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            break;
        
        case EaseTypeSineIn:
            return [CAMediaTimingFunction functionWithControlPoints:0.45 :0 :1 :1];
            break;
        case EaseTypeSineOut:
            return [CAMediaTimingFunction functionWithControlPoints:0 :0 :0.55 :1];
            break;
        case EaseTypeSineInOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.45 :0 :0.55 :1];
            break;
        
        case EaseTypeQuadIn:
            return [CAMediaTimingFunction functionWithControlPoints:0.43 :0 :0.82 :0.60];
            break;
        case EaseTypeQuadOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.18 :0.4 :0.57 :1];
            break;
        case EaseTypeQuadInOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.43 :0 :0.57 :1];
            break;
        
        case EaseTypeCubicIn:
            return [CAMediaTimingFunction functionWithControlPoints:0.67 :0 :0.84 :0.54];
            break;
        case EaseTypeCubicOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.16 :0.46 :0.33 :1];
            break;
        case EaseTypeCubicInOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.65 :0 :0.35 :1];
            break;
            
        case EaseTypeQuartIn:
            return [CAMediaTimingFunction functionWithControlPoints:0.81 :0 :0.77 :0.34];
            break;
        case EaseTypeQuartOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.23 :0.66 :0.19 :1];
            break;
        case EaseTypeQuartInOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.81 :0 :0.19 :1];
            break;
            
        case EaseTypeQuintIn:
            return [CAMediaTimingFunction functionWithControlPoints:0.89 :0 :0.81 :0.27];
            break;
        case EaseTypeQuintOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.19 :0.73 :0.11 :1];
            break;
        case EaseTypeQuintInOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.9 :0 :0.1 :1];
            break;
            
        case EaseTypeExpoIn:
            return [CAMediaTimingFunction functionWithControlPoints:1.04 :0 :0.88 :0.49];
            break;
        case EaseTypeExpoOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.0 :0.0 :0.25 :1];
            break;
        case EaseTypeExpoInOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.95 :0 :0.05 :1];
            break;
        
        case EaseTypeCircIn:
            return [CAMediaTimingFunction functionWithControlPoints:0.6 :0 :1 :0.45];
            break;
        case EaseTypeCircOut:
            return [CAMediaTimingFunction functionWithControlPoints:1 :0.55 :0.4 :1];
            break;
        case EaseTypeCircInOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.82 :0 :0.18 :1];
            break;
            
        case EaseTypeBackIn:
            return [CAMediaTimingFunction functionWithControlPoints:0.77 :-0.63 :1 :1];
            break;
        case EaseTypeBackOut:
            return [CAMediaTimingFunction functionWithControlPoints:0 :0 :0.23 :1.37];
            break;
        case EaseTypeBackInOut:
            return [CAMediaTimingFunction functionWithControlPoints:0.77 :-0.63 :0.23 :1.37];
            break;
        default:
            break;
    }
    
    return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
}

@end
