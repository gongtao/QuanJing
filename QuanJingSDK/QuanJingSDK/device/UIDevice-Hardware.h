//
//  UIDevice-Hardware.h
//  MiCloudSDK
//
//  Created by Gongtao on 14-10-16.
//  Copyright (c) 2014年 xiaomi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import <CoreTelephony/CTCarrier.h>

#ifndef UIDevice_Hardware_h

  #define UIDevice_Hardware_h
  
	@interface UIDevice (Hardware)
	
	- (NSString *)getSysInfoByName:(char *)typeSpecifier;
	
	- (NSString *)ROM;
	
	- (NSString *)machine;
	
	- (NSString *)platformString;
	
	- (NSString *)deviceModel;
	
	@end
#endif
