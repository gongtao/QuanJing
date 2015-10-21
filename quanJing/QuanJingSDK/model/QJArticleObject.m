//
//  QJArticleObject.m
//  QuanJingSDK
//
//  Created by QJ on 15/10/21.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import "QJArticleObject.h"

#import "QJCoreMacros.h"

@implementation QJArticleObject

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
		
	// categoryId
	NSNumber * categoryId = json[@"categoryId"];
	
	if (!QJ_IS_NUM_NIL(categoryId))
		self.categoryId = categoryId;
		
	// title
	NSString * title = json[@"title"];
	
	if (!QJ_IS_STR_NIL(title))
		self.title = title;
		
	// subtitle
	NSString * subtitle = json[@"subtitle"];
	
	if (!QJ_IS_STR_NIL(subtitle))
		self.subtitle = subtitle;
		
	// summary
	NSString * summary = json[@"summary"];
	
	if (!QJ_IS_STR_NIL(summary))
		self.summary = summary;
		
	// categoryName
	NSString * categoryName = json[@"categoryName"];
	
	if (!QJ_IS_STR_NIL(categoryName))
		self.categoryName = categoryName;
		
	// content
	NSString * content = json[@"content"];
	
	if (!QJ_IS_STR_NIL(content))
		self.content = content;
		
	// coverId
	NSNumber * coverId = json[@"coverId"];
	
	if (!QJ_IS_NUM_NIL(coverId))
		self.coverId = coverId;
		
	// coverUrl
	NSString * coverUrl = json[@"coverUrl"];
	
	if (!QJ_IS_STR_NIL(coverUrl))
		self.coverUrl = coverUrl;
		
	// creatTime
	NSNumber * creatTime = json[@"creatTime"];
	
	if (!QJ_IS_NUM_NIL(creatTime))
		self.creatTime = [NSDate dateWithTimeIntervalSince1970:creatTime.longLongValue];
		
	// updateTime
	NSNumber * updateTime = json[@"updateTime"];
	
	if (!QJ_IS_NUM_NIL(updateTime))
		self.updateTime = [NSDate dateWithTimeIntervalSince1970:updateTime.longLongValue];
}

@end
