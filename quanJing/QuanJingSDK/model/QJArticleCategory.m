//
//  QJArticleCategory.m
//  QuanJingSDK
//
//  Created by QJ on 15/10/21.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import "QJArticleCategory.h"

#import "QJCoreMacros.h"

@implementation QJArticleCategory

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
		
	// cid
	NSNumber * cid = json[@"id"];
	
	if (!QJ_IS_NUM_NIL(cid))
		self.cid = cid;
		
	// name
	NSString * name = json[@"name"];
	
	if (!QJ_IS_STR_NIL(name))
		self.name = name;
		
	// creatTime
	NSNumber * creatTime = json[@"creatTime"];
	
	if (!QJ_IS_NUM_NIL(creatTime))
		self.creatTime = [NSDate dateWithTimeIntervalSince1970:creatTime.longLongValue];
}

@end
