//
//  QJImageCategory.m
//  QuanJingSDK
//
//  Created by QJ on 15/10/19.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import "QJImageCategory.h"

#import "QJCoreMacros.h"

@implementation QJImageCategory

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
		
	// id
	NSNumber * cid = json[@"id"];
	
	if (!QJ_IS_NUM_NIL(cid))
		self.cid = cid;
		
	// parentId
	NSNumber * parentId = json[@"parentId"];
	
	if (!QJ_IS_NUM_NIL(parentId))
		self.parentId = parentId;
		
	// image
	NSString * image = json[@"image"];
	
	if (!QJ_IS_STR_NIL(image))
		self.image = image;
		
	// imageCount
	NSNumber * imageCount = json[@"imageCount"];
	
	if (!QJ_IS_NUM_NIL(imageCount))
		self.imageCount = imageCount;
		
	// name
	NSString * name = json[@"name"];
	
	if (!QJ_IS_STR_NIL(name))
		self.name = name;
}

@end
