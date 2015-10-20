//
//  QJUser.m
//  QuanJingSDK
//
//  Created by QJ on 15/10/19.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import "QJUser.h"

#import "QJCoreMacros.h"

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
		
		
	// age
	NSString * age = json[@"age"];
	
	if (!QJ_IS_STR_NIL(age))
		self.age = age;
		
	// avatar
	NSString * avatar = json[@"avatar"];
	
	if (!QJ_IS_STR_NIL(avatar))
		self.avatar = avatar;
		
	// bornArea
	NSString * bornArea = json[@"bornArea"];
	
	if (!QJ_IS_STR_NIL(bornArea))
		self.bornArea = bornArea;
		
	// collectAmount
	NSNumber * collectAmount = json[@"collectAmount"];
	
	if (!QJ_IS_NUM_NIL(collectAmount))
		self.collectAmount = collectAmount;
		
	// creatTime
	NSNumber * creatTime = json[@"creatTime"];
	
	if (!QJ_IS_NUM_NIL(creatTime))
		self.creatTime = [NSDate dateWithTimeIntervalSince1970:creatTime.longLongValue];
		
	// email
	NSString * email = json[@"email"];
	
	if (!QJ_IS_STR_NIL(email))
		self.email = email;
		
	// fansAmount
	NSNumber * fansAmount = json[@"fansAmount"];
	
	if (!QJ_IS_NUM_NIL(fansAmount))
		self.fansAmount = fansAmount;
		
	// followAmount
	NSNumber * followAmount = json[@"followAmount"];
	
	if (!QJ_IS_NUM_NIL(followAmount))
		self.followAmount = followAmount;
		
	// gender
	NSNumber * gender = json[@"gender"];
	
	if (!QJ_IS_NUM_NIL(gender))
		self.followAmount = gender;
		
	// goodAt
	NSString * goodAt = json[@"goodAt"];
	
	if (!QJ_IS_STR_NIL(goodAt))
		self.goodAt = goodAt;
		
	// uid
	NSNumber * uid = json[@"id"];
	
	if (!QJ_IS_NUM_NIL(uid))
		self.uid = uid;
		
	// interest
	NSString * interest = json[@"interest"];
	
	if (!QJ_IS_STR_NIL(interest))
		self.interest = interest;
		
	// introduce
	NSString * introduce = json[@"introduce"];
	
	if (!QJ_IS_STR_NIL(introduce))
		self.introduce = introduce;
		
	// job
	NSString * job = json[@"job"];
	
	if (!QJ_IS_STR_NIL(job))
		self.job = job;
		
	// lastLoginTime
	NSNumber * lastLoginTime = json[@"lastLoginTime"];
	
	if (!QJ_IS_NUM_NIL(lastLoginTime))
		self.lastLoginTime = [NSDate dateWithTimeIntervalSince1970:lastLoginTime.longLongValue];
		
	// maritalStatus
	NSString * maritalStatus = json[@"maritalStatus"];
	
	if (!QJ_IS_STR_NIL(maritalStatus))
		self.maritalStatus = maritalStatus;
		
	// nickName
	NSString * nickName = json[@"nickName"];
	
	if (!QJ_IS_STR_NIL(nickName))
		self.nickName = nickName;
		
	// password
	NSString * password = json[@"password"];
	
	if (!QJ_IS_STR_NIL(password))
		self.password = password;
		
	// phone
	NSString * phone = json[@"phone"];
	
	if (!QJ_IS_STR_NIL(phone))
		self.phone = phone;
		
	// qq
	NSString * qq = json[@"qq"];
	
	if (!QJ_IS_STR_NIL(qq))
		self.qq = qq;
		
	// realName
	NSString * realName = json[@"realName"];
	
	if (!QJ_IS_STR_NIL(realName))
		self.realName = realName;
		
	// residence
	NSString * residence = json[@"residence"];
	
	if (!QJ_IS_STR_NIL(residence))
		self.residence = residence;
		
	// starSign
	NSString * starSign = json[@"starSign"];
	
	if (!QJ_IS_STR_NIL(starSign))
		self.starSign = starSign;
		
	// stayArea
	NSString * stayArea = json[@"stayArea"];
	
	if (!QJ_IS_STR_NIL(stayArea))
		self.stayArea = stayArea;
		
	// stayAreaAddress
	NSString * stayAreaAddress = json[@"stayAreaAddress"];
	
	if (!QJ_IS_STR_NIL(stayAreaAddress))
		self.stayAreaAddress = stayAreaAddress;
		
	// uploadAmount
	NSNumber * uploadAmount = json[@"uploadAmount"];
	
	if (!QJ_IS_NUM_NIL(uploadAmount))
		self.uploadAmount = uploadAmount;
		
	// userName
	NSString * userName = json[@"userName"];
	
	if (!QJ_IS_STR_NIL(userName))
		self.userName = userName;
		
	// website
	NSString * website = json[@"website"];
	
	if (!QJ_IS_STR_NIL(website))
		self.website = website;
}

@end
