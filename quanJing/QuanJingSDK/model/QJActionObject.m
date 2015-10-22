//
//  QJActionObject.m
//  QuanJingSDK
//
//  Created by QJ on 15/10/20.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import "QJActionObject.h"

#import "QJCoreMacros.h"

@implementation QJActionObject

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
		
	// comment
	NSArray * comments = json[@"comment"];
	
	if (!QJ_IS_ARRAY_NIL(comments)) {
		__block NSMutableArray * array = [[NSMutableArray alloc] init];
		[comments enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * stop) {
			[array addObject:[[QJCommentObject alloc] initWithJson:obj]];
		}];
		self.comments = array;
	}
	
	// content
	NSString * content = json[@"content"];
	
	if (!QJ_IS_STR_NIL(content))
		self.content = content;
		
	// creatTime
	NSNumber * creatTime = json[@"creatTime"];
	
	if (!QJ_IS_NUM_NIL(creatTime))
		self.creatTime = [NSDate dateWithTimeIntervalSince1970:creatTime.longLongValue / 1000.0];
		
	// aid
	NSNumber * aid = json[@"id"];
	
	if (!QJ_IS_NUM_NIL(aid))
		self.aid = aid;
		
	// like
	NSArray * likes = json[@"like"];
	
	if (!QJ_IS_ARRAY_NIL(likes)) {
		__block NSMutableArray * array = [[NSMutableArray alloc] init];
		[likes enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * stop) {
			[array addObject:[[QJUser alloc] initWithJson:obj]];
		}];
		self.likes = array;
	}
	
	// type
	NSNumber * type = json[@"type"];
	
	if (!QJ_IS_NUM_NIL(type))
		self.type = type;
		
	// user
	NSDictionary * user = json[@"user"];
	
	if (!QJ_IS_DICT_NIL(user))
		self.user = [[QJUser alloc] initWithJson:user];
		
	// userId
	NSNumber * userId = json[@"userId"];
	
	if (!QJ_IS_NUM_NIL(userId))
		self.userId = userId;
}

@end
