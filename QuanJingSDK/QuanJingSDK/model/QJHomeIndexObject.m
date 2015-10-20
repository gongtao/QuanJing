//
//  QJHomeIndexObject.m
//  QuanJingSDK
//
//  Created by QJ on 15/10/19.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import "QJHomeIndexObject.h"

#import "QJCoreMacros.h"

@implementation QJHomeIndexObject

- (instancetype)initWithJson:(NSDictionary *)json
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
		
	NSNumber * creatTime = json[@"creatTime"];
	
	if (!QJ_IS_NUM_NIL(creatTime))
		self.creatTime = [NSDate dateWithTimeIntervalSince1970:creatTime.longLongValue];
		
	NSString * imageUrl = json[@"imageUrl"];
	
	if (!QJ_IS_STR_NIL(imageUrl))
		self.imageUrl = imageUrl;
		
	NSString * linkData = json[@"linkData"];
	
	if (!QJ_IS_STR_NIL(linkData)) {
		NSArray * array = [linkData componentsSeparatedByString:@":"];
		
		if (!QJ_IS_ARRAY_NIL(array) && (array.count == 2)) {
			self.type = [array firstObject];
			self.typeValue = [array lastObject];
		}
	}
	
	NSString * position = json[@"position"];
	
	if (!QJ_IS_STR_NIL(position))
		self.position = position;
		
	NSString * text1 = json[@"text1"];
	
	if (!QJ_IS_STR_NIL(text1))
		self.title = text1;
		
	NSString * text2 = json[@"text2"];
	
	if (!QJ_IS_STR_NIL(text2))
		self.detailText = text2;
}

@end
