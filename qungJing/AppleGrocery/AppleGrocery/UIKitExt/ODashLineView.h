#pragma once

#import <UIKit/UIKit.h>

@interface ODashLineView : UIView
{
    float _lineWidth;
}

@property (nonatomic) float lineWidth;
@property (nonatomic) BOOL vertical;
@property (strong, nonatomic) NSArray* dashes;
@property (strong, nonatomic) UIColor* lineColor;

@end
