//
//  UIImage+addtion.h
//  追梦
//
//  Created by denghs on 15/1/30.
//  Copyright (c) 2015年 Renrui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (addtion)

//改变Image的size
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;

//uiview 生成image图片
-(UIImage *)getImageFromView:(UIView *)view;

//改变image的背景颜色 适用于只要一张图片 去做button
-(UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
@end