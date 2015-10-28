//
//  QJUser.m
//  QuanJingSDK
//
//  Created by QJ on 15/10/19.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import "QJUser.h"

#import "QJCoreMacros.h"

#import "QJUtils.h"

@implementation QJUser

- (instancetype)initWithJson:(nullable NSDictionary *)json
{
	self = [super init];
	
	if (self)
		[self setPropertiesFromJson:json];
	return self;
}

- (void)setPropertiesFromJson:(NSDictionary *)json
{
	if (QJ_IS_DICT_NIL(json))
		return;
		
	// uid
	NSNumber * uid = json[@"id"];
	
	if (!QJ_IS_NUM_NIL(uid)) {
		self.uid = uid;
	}
	else {
		NSNumber * userId = json[@"userId"];
		
		if (!QJ_IS_NUM_NIL(userId))
			self.uid = userId;
	}
	
	// nickName
	NSString * nickName = json[@"nickName"];
	
	if (!QJ_IS_STR_NIL(nickName)) {
		self.nickName = nickName;
	}
	else {
		NSString * nickname = json[@"nickname"];
		
		if (!QJ_IS_STR_NIL(nickname))
			self.nickName = nickname;
		else
			self.nickName = nil;
	}
	
	// age
	NSString * age = json[@"age"];
	
	if (!QJ_IS_STR_NIL(age))
		self.age = age;
	else
		self.age = nil;
		
	// avatar
	NSString * avatar = json[@"avatar"];
	
	if (!QJ_IS_STR_NIL(avatar))
		self.avatar = [QJUtils realImageUrlFromServerUrl:avatar];
	else
		self.avatar = nil;
		
	// bornArea
	NSNumber * bornArea = json[@"bornArea"];
	
	if (!QJ_IS_NUM_NIL(bornArea))
		self.bornArea = bornArea;
	else
		self.bornArea = nil;
		
	// collectAmount
	NSNumber * collectAmount = json[@"collectAmount"];
	
	if (!QJ_IS_NUM_NIL(collectAmount))
		self.collectAmount = collectAmount;
	else
		self.collectAmount = nil;
		
	// creatTime
	NSNumber * creatTime = json[@"creatTime"];
	
	if (!QJ_IS_NUM_NIL(creatTime))
		self.creatTime = [NSDate dateWithTimeIntervalSince1970:creatTime.longLongValue / 1000.0];
	else
		self.creatTime = nil;
		
	// email
	NSString * email = json[@"email"];
	
	if (!QJ_IS_STR_NIL(email))
		self.email = email;
	else
		self.email = nil;
		
	// fansAmount
	NSNumber * fansAmount = json[@"fansAmount"];
	
	if (!QJ_IS_NUM_NIL(fansAmount))
		self.fansAmount = fansAmount;
	else
		self.fansAmount = nil;
		
	// followAmount
	NSNumber * followAmount = json[@"followAmount"];
	
	if (!QJ_IS_NUM_NIL(followAmount))
		self.followAmount = followAmount;
	else
		self.followAmount = nil;
		
	// gender
	NSNumber * gender = json[@"gender"];
	
	if (!QJ_IS_NUM_NIL(gender))
		self.gender = gender;
	else
		self.gender = nil;
		
	// goodAt
	NSString * goodAt = json[@"goodAt"];
	
	if (!QJ_IS_STR_NIL(goodAt))
		self.goodAt = goodAt;
	else
		self.goodAt = nil;
		
	// interest
	NSString * interest = json[@"interest"];
	
	if (!QJ_IS_STR_NIL(interest))
		self.interest = interest;
	else
		self.interest = nil;
		
	// introduce
	NSString * introduce = json[@"introduce"];
	
	if (!QJ_IS_STR_NIL(introduce))
		self.introduce = introduce;
	else
		self.introduce = nil;
		
	// job
	NSString * job = json[@"job"];
	
	if (!QJ_IS_STR_NIL(job))
		self.job = job;
	else
		self.job = nil;
		
	// lastLoginTime
	NSNumber * lastLoginTime = json[@"lastLoginTime"];
	
	if (!QJ_IS_NUM_NIL(lastLoginTime))
		self.lastLoginTime = [NSDate dateWithTimeIntervalSince1970:lastLoginTime.longLongValue / 1000.0];
	else
		self.lastLoginTime = nil;
		
	// maritalStatus
	NSString * maritalStatus = json[@"maritalStatus"];
	
	if (!QJ_IS_STR_NIL(maritalStatus))
		self.maritalStatus = maritalStatus;
	else
		self.maritalStatus = nil;
		
	// password
	NSString * password = json[@"password"];
	
	if (!QJ_IS_STR_NIL(password))
		self.password = password;
	else
		self.password = nil;
		
	// phone
	NSString * phone = json[@"phone"];
	
	if (!QJ_IS_STR_NIL(phone))
		self.phone = phone;
	else
		self.phone = nil;
		
	// qq
	NSString * qq = json[@"qq"];
	
	if (!QJ_IS_STR_NIL(qq))
		self.qq = qq;
	else
		self.qq = nil;
		
	// realName
	NSString * realName = json[@"realName"];
	
	if (!QJ_IS_STR_NIL(realName))
		self.realName = realName;
	else
		self.realName = nil;
		
	// residence
	NSNumber * residence = json[@"residence"];
	
	if (!QJ_IS_NUM_NIL(residence))
		self.residence = residence;
	else
		self.residence = nil;
		
	// starSign
	NSString * starSign = json[@"starSign"];
	
	if (!QJ_IS_STR_NIL(starSign))
		self.starSign = starSign;
	else
		self.starSign = nil;
		
	// stayArea
	NSNumber * stayArea = json[@"stayArea"];
	
	if (!QJ_IS_NUM_NIL(stayArea))
		self.stayArea = stayArea;
	else
		self.stayArea = nil;
		
	// stayAreaAddress
	NSNumber * stayAreaAddress = json[@"stayAreaAddress"];
	
	if (!QJ_IS_NUM_NIL(stayAreaAddress))
		self.stayAreaAddress = stayAreaAddress;
	else
		self.stayAreaAddress = nil;
		
	// uploadAmount
	NSNumber * uploadAmount = json[@"uploadAmount"];
	
	if (!QJ_IS_NUM_NIL(uploadAmount))
		self.uploadAmount = uploadAmount;
	else
		self.uploadAmount = nil;
		
	// userName
	NSString * userName = json[@"userName"];
	
	if (!QJ_IS_STR_NIL(userName))
		self.userName = userName;
	else
		self.userName = nil;
		
	// website
	NSString * website = json[@"website"];
	
	if (!QJ_IS_STR_NIL(website))
		self.website = website;
	else
		self.website = nil;
}

@end
