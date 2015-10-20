//
//  UIDevice-Hardware.m
//  MiCloudSDK
//
//  Created by Gongtao on 14-10-16.
//  Copyright (c) 2014年 xiaomi. All rights reserved.
//

#import "UIDevice-Hardware.h"

#import <sys/sysctl.h>

extern NSString *CTSettingCopyMyPhoneNumber();

@implementation UIDevice (Hardware)

- (NSString *)getSysInfoByName:(char *)typeSpecifier
{
	size_t size;
	
	sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
	
	char * answer = malloc(size);
	sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
	
	NSString * results = [NSString stringWithCString:answer encoding:NSUTF8StringEncoding];
	
	free(answer);
	return results;
}

- (NSString *)ROM
{
	return [NSString stringWithFormat:@"%@ %@", [self getSysInfoByName:"kern.ostype"], [self getSysInfoByName:"kern.osrelease"]];
}

- (NSString *)machine
{
	return [self getSysInfoByName:"hw.machine"];
}

- (NSString *)platformString
{
	NSString * machine = [self machine];
	
	NSDictionary * modelDic = @{
		@"i386": @"iPhone Simulator",
		@"x86_64": @"iPhone Simulator",
		
		@"iPhone1,1": @"iPhone 2G",
		@"iPhone1,2": @"iPhone 3G",
		@"iPhone2,1": @"iPhone 3GS",
		@"iPhone3,1": @"iPhone 4(GSM)",
		@"iPhone3,2": @"iPhone 4(GSM Rev A)",
		@"iPhone3,3": @"iPhone 4(CDMA)",
		@"iPhone4,1": @"iPhone 4S",
		@"iPhone5,1": @"iPhone 5(GSM)",
		@"iPhone5,2": @"iPhone 5(GSM+CDMA)",
		@"iPhone5,3": @"iPhone 5c(GSM)",
		@"iPhone5,4": @"iPhone 5c(Global)",
		@"iPhone6,1": @"iPhone 5s(GSM)",
		@"iPhone6,2": @"iPhone 5s(Global)",
		@"iPhone7,1": @"iphone 6",
		@"iPhone7,2": @"iphone 6 plus",
		
		@"iPod1,1": @"iPod Touch 1G",
		@"iPod2,1": @"iPod Touch 2G",
		@"iPod3,1": @"iPod Touch 3G",
		@"iPod4,1": @"iPod Touch 4G",
		@"iPod5,1": @"iPod Touch 5G",
		
		@"iPad1,1": @"iPad",
		@"iPad2,1": @"iPad 2(WiFi)",
		@"iPad2,2": @"iPad 2(GSM)",
		@"iPad2,3": @"iPad 2(CDMA)",
		@"iPad2,4": @"iPad 2(WiFi+New Chip)",
		@"iPad3,1": @"iPad 3(WiFi)",
		@"iPad3,2": @"iPad 3(GSM+CDMA)",
		@"iPad3,3": @"iPad 3(GSM)",
		@"iPad3,4": @"iPad 4(WiFi)",
		@"iPad3,5": @"iPad 4(GSM)",
		@"iPad3,6": @"iPad 4(GSM+CDMA)",
		@"iPad4,1": @"iPad Air(WiFi)",
		@"iPad4,2": @"iPad Air(GSM)",
		@"iPad4,3": @"iPad Air(GSM+CDMA)",
		
		@"iPad2,5": @"iPad mini(WiFi)",
		@"iPad2,6": @"iPad mini(GSM)",
		@"iPad2,7": @"ipad mini(GSM+CDMA)",
		@"iPad4,4": @"iPad mini 2(WiFi)",
		@"iPad4,5": @"iPad mini 2(GSM)",
		@"iPad4,6": @"ipad mini 2(GSM+CDMA)"
	};
	
	NSString * modal = modelDic[machine];
	
	if (!modal)
		modal = machine;
	return modal;
}

- (NSString *)deviceModel
{
	NSString * machine = [self machine];
	
	NSDictionary * modelDic = @{
		@"i386": @"iPhone Simulator",
		@"x86_64": @"iPhone Simulator",
		
		@"iPhone1,1": @"iPhone 2G",
		@"iPhone1,2": @"iPhone 3G",
		@"iPhone2,1": @"iPhone 3GS",
		@"iPhone3,1": @"iPhone 4",
		@"iPhone3,2": @"iPhone 4",
		@"iPhone3,3": @"iPhone 4",
		@"iPhone4,1": @"iPhone 4S",
		@"iPhone5,1": @"iPhone 5",
		@"iPhone5,2": @"iPhone 5",
		@"iPhone5,3": @"iPhone 5c",
		@"iPhone5,4": @"iPhone 5c",
		@"iPhone6,1": @"iPhone 5s",
		@"iPhone6,2": @"iPhone 5s",
		@"iPhone7,1": @"iphone 6",
		@"iPhone7,2": @"iphone 6 plus",
		
		@"iPod1,1": @"iPod Touch 1G",
		@"iPod2,1": @"iPod Touch 2G",
		@"iPod3,1": @"iPod Touch 3G",
		@"iPod4,1": @"iPod Touch 4G",
		@"iPod5,1": @"iPod Touch 5G",
		
		@"iPad1,1": @"iPad",
		@"iPad2,1": @"iPad 2",
		@"iPad2,2": @"iPad 2",
		@"iPad2,3": @"iPad 2",
		@"iPad2,4": @"iPad 2",
		@"iPad3,1": @"iPad 3",
		@"iPad3,2": @"iPad 3",
		@"iPad3,3": @"iPad 3",
		@"iPad3,4": @"iPad 4",
		@"iPad3,5": @"iPad 4",
		@"iPad3,6": @"iPad 4",
		@"iPad4,1": @"iPad Air",
		@"iPad4,2": @"iPad Air",
		@"iPad4,3": @"iPad Air",
		
		@"iPad2,5": @"iPad mini",
		@"iPad2,6": @"iPad mini",
		@"iPad2,7": @"ipad mini",
		@"iPad4,4": @"iPad mini 2",
		@"iPad4,5": @"iPad mini 2",
		@"iPad4,6": @"ipad mini 2"
	};
	
	NSString * modal = modelDic[machine];
	
	if (!modal)
		modal = [self model];
	return modal;
}

@end
