//
//  QJAlbumObject.m
//  QuanJingSDK
//
//  Created by QJ on 15/10/25.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import "QJAlbumObject.h"

#import "QJCoreMacros.h"

@implementation QJAlbumObject

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
		
	// aid
	NSNumber * aid = json[@"id"];
	
	if (!QJ_IS_NUM_NIL(aid))
		self.aid = aid;
		
	// userId
	NSNumber * userId = json[@"userId"];
	
	if (!QJ_IS_NUM_NIL(userId))
		self.userId = userId;
		
	// name
	NSString * name = json[@"name"];
	
	if (!QJ_IS_NUM_NIL(name))
		self.name = name;
		
	// creatTime
	NSNumber * creatTime = json[@"creatTime"];
	
	if (!QJ_IS_NUM_NIL(creatTime))
		self.creatTime = [NSDate dateWithTimeIntervalSince1970:creatTime.longLongValue / 1000.0];
}

@end
