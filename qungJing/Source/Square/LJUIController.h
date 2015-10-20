//
//  LJUIController.h
//  Weitu
//
//  Created by qj-app on 15/5/19.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LJUIController : NSObject

#pragma mark --判断设备型号
+ (NSString *)platFormString;
#pragma mark --创建label
+ (UILabel *)createLabelWithFrame:(CGRect)frame Font:(int)font Text:(NSString *)text;
#pragma mark --创建button
+ (UIButton *)createButtonWithFrame:(CGRect)frame imageName:(NSString *)imageName title:(NSString *)title target:(id)target action:(SEL)action;
#pragma mark --创建imageView
+ (UIImageView *)createImageViewWithFrame:(CGRect)frame imageName:(NSString *)imageName;
#pragma mark --创建UITextField
+ (UITextField *)createTextFieldWithFrame:(CGRect)frame placeholder:(NSString *)placeholder passWord:(BOOL)YESorNO leftImageView:(UIImageView *)imageView rightImageView:(UIImageView *)rightImageView Font:(float)font backgRoundImageName:(NSString *)imageName;
+ (float)isIOS7;
+ (UIImageView *)createCircularImageViewWithFrame:(CGRect)frame imageName:(NSString *)imageName;
+ (UIImage *)clipImage:(UIImage *)image withRect:(CGRect)rect;
@end
