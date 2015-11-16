//
//  LJUIController.m
//  Weitu
//
//  Created by qj-app on 15/5/19.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJUIController.h"
#define IOS7 [[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0
@implementation LJUIController
#pragma mark --判断设备型号
+ (NSString *)platFormString
{
	return [UIDevice currentDevice].name;
}

#pragma mark --创建label
+ (UILabel *)createLabelWithFrame:(CGRect)frame Font:(int)font Text:(NSString *)text
{
	UILabel * label = [[UILabel alloc]initWithFrame:frame];
	
	label.numberOfLines = 0;
	label.textAlignment = NSTextAlignmentLeft;
	label.font = [UIFont systemFontOfSize:font];
	label.lineBreakMode = NSLineBreakByClipping;
	label.adjustsFontSizeToFitWidth = YES;
	label.text = text;
	return label;
}

#pragma mark --创建button
+ (UIButton *)createButtonWithFrame:(CGRect)frame imageName:(NSString *)imageName title:(NSString *)title target:(id)target action:(SEL)action
{
	UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
	
	button.frame = frame;
	[button setTitle:title forState:UIControlStateNormal];
	// 设置背景图片，可以使文字与图片共存
	[button setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
	// 图片与文字如果需要同时存在，就需要图片足够小 详见人人项目按钮设置
	// [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	return button;
}

#pragma mark --创建imageView
+ (UIImageView *)createImageViewWithFrame:(CGRect)frame imageName:(NSString *)imageName
{
	UIImageView * imageView = [[UIImageView alloc] initWithFrame:frame];
	
	imageView.image = [UIImage imageNamed:imageName];
	imageView.userInteractionEnabled = YES;
	return imageView;
}

+ (UIImageView *)createCircularImageViewWithFrame:(CGRect)frame imageName:(NSString *)imageName
{
	UIImageView * imageView = [[UIImageView alloc]initWithFrame:frame];
	
	imageView.image = [UIImage imageNamed:imageName];
	imageView.layer.masksToBounds = YES;
	imageView.layer.cornerRadius = frame.size.height / 2;
	imageView.userInteractionEnabled = YES;
	return imageView;
}

#pragma mark --创建UITextField
+ (UITextField *)createTextFieldWithFrame:(CGRect)frame placeholder:(NSString *)placeholder passWord:(BOOL)YESorNO leftImageView:(UIImageView *)imageView rightImageView:(UIImageView *)rightImageView Font:(float)font backgRoundImageName:(NSString *)imageName
{
	UITextField * textField = [[UITextField alloc]initWithFrame:frame];
	
	textField.placeholder = placeholder;
	textField.secureTextEntry = YESorNO;
	textField.leftView = imageView;
	textField.rightView = rightImageView;
	textField.keyboardType = UIKeyboardTypeEmailAddress;
	textField.autocapitalizationType = NO;
	textField.clearButtonMode = YES;
	textField.font = [UIFont systemFontOfSize:font];
	textField.textColor = [UIColor blackColor];
	textField.backgroundColor = [UIColor whiteColor];
	return textField;
}

#pragma mark --切图
+ (UIImage *)clipImage:(UIImage *)image withRect:(CGRect)rect
{
	CGImageRef imageref = CGImageCreateWithImageInRect(image.CGImage, rect);
	UIImage * image1 = [UIImage imageWithCGImage:imageref];
	
	return image1;
}

+ (float)isIOS7
{
	if (IOS7)
		return 64;
	else
		return 44;
}

@end
