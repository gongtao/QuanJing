//
//  QJImageObject.m
//  QuanJingSDK
//
//  Created by QJ on 15/10/19.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import "QJImageObject.h"

#import "QJCoreMacros.h"

#import "QJUtils.h"

@implementation QJImageObject

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
		
	// imageId
	NSNumber * imageId = json[@"id"];
	
	if (!QJ_IS_NUM_NIL(imageId)) {
		self.imageId = imageId;
	}
	else {
		imageId = json[@"imageId"];
		
		if (!QJ_IS_NUM_NIL(imageId))
			self.imageId = imageId;
	}
	
	// userId
	NSNumber * userId = json[@"userId"];
	
	if (!QJ_IS_NUM_NIL(userId))
		self.userId = userId;
		
	// albumId
	NSNumber * albumId = json[@"albumId"];
	
	if (!QJ_IS_NUM_NIL(albumId))
		self.albumId = albumId;
		
	// tag
	NSString * tag = json[@"tag"];
	
	if (!QJ_IS_STR_NIL(tag))
		self.tag = tag;
		
	// title
	NSString * title = json[@"title"];
	
	if (!QJ_IS_STR_NIL(title))
		self.title = title;
		
	// url
	NSString * url = json[@"url"];
	
	if (!QJ_IS_STR_NIL(url)) {
		self.url = [QJUtils realImageUrlFromServerUrl:url];
	}
	else {
		NSString * imageUrl = json[@"imageUrl"];
		
		if (!QJ_IS_STR_NIL(imageUrl))
			self.url = [QJUtils realImageUrlFromServerUrl:imageUrl];
	}
	
	// bgcolor
	NSString * bgcolor = json[@"bgcolor"];
	
	if (!QJ_IS_STR_NIL(bgcolor))
		self.bgcolor = bgcolor;
		
	// width
	NSNumber * width = json[@"width"];
	
	if (!QJ_IS_NUM_NIL(width))
		self.width = width;
		
	// height
	NSNumber * height = json[@"height"];
	
	if (!QJ_IS_NUM_NIL(height))
        self.height = height;
    
    // picId
    NSString * picId = json[@"picId"];
    
    if (!QJ_IS_STR_NIL(picId))
        self.picId = picId;
		
	// imageType
	NSNumber * imageType = json[@"imageType"];
	
	if (!QJ_IS_NUM_NIL(imageType))
		self.imageType = imageType;
		
	// brand
	NSString * brand = json[@"brand"];
	
	if (!QJ_IS_STR_NIL(brand))
		self.brand = brand;
		
	// captionCn
	NSString * captionCn = json[@"captionCn"];
	
	if (!QJ_IS_STR_NIL(captionCn))
		self.brand = captionCn;
		
	// captionEn
	NSString * captionEn = json[@"captionEn"];
	
	if (!QJ_IS_STR_NIL(captionEn))
		self.captionEn = captionEn;
		
	// categoryId
	NSNumber * categoryId = json[@"categoryId"];
	
	if (!QJ_IS_NUM_NIL(categoryId))
		self.categoryId = categoryId;
		
	// comment
	NSArray * commentArray = json[@"comment"];
	
	if (!QJ_IS_ARRAY_NIL(commentArray)) {
		__block NSMutableArray * resultArray = [[NSMutableArray alloc] initWithCapacity:commentArray.count];
		[commentArray enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * stop) {
			[resultArray addObject:[[QJCommentObject alloc] initWithJson:obj]];
		}];
		self.comments = resultArray;
	}
	
	// creatTime
	NSNumber * creatTime = json[@"creatTime"];
	
	if (!QJ_IS_NUM_NIL(creatTime))
		self.creatTime = [NSDate dateWithTimeIntervalSince1970:creatTime.longLongValue / 1000.0];
		
	// descript
	NSString * descript = json[@"descript"];
	
	if (!QJ_IS_STR_NIL(descript))
		self.descript = descript;
		
	// downloadTimes
	NSNumber * downloadTimes = json[@"downTimes"];
	
	if (!QJ_IS_NUM_NIL(downloadTimes))
		self.downloadTimes = downloadTimes;
		
	// hvsp
	NSString * hvsp = json[@"hvsp"];
	
	if (!QJ_IS_STR_NIL(hvsp))
		self.hvsp = hvsp;
		
	// like
	NSArray * likeArray = json[@"like"];
	
	if (!QJ_IS_ARRAY_NIL(likeArray)) {
		__block NSMutableArray * resultArray = [[NSMutableArray alloc] initWithCapacity:likeArray.count];
		[likeArray enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * stop) {
			[resultArray addObject:[[QJUser alloc] initWithJson:obj]];
		}];
		self.likes = resultArray;
	}
	
	// md5
	NSString * md5 = json[@"md5"];
	
	if (!QJ_IS_STR_NIL(md5))
		self.md5 = md5;
		
	// modelRelease
	NSString * modelRelease = json[@"modelRelease"];
	
	if (!QJ_IS_STR_NIL(modelRelease))
		self.modelRelease = modelRelease;
		
	// permissions
	NSString * permissions = json[@"permissions"];
	
	if (!QJ_IS_STR_NIL(permissions))
		self.permissions = permissions;
		
	// photographer
	NSString * photographer = json[@"photographer"];
	
	if (!QJ_IS_STR_NIL(photographer))
		self.photographer = photographer;
		
	// picType
	NSNumber * picType = json[@"picType"];
	
	if (!QJ_IS_NUM_NIL(picType))
		self.picType = picType;
		
	// shootingDate
	NSNumber * shootingDate = json[@"shootingDate"];
	
	if (!QJ_IS_NUM_NIL(shootingDate))
		self.shootingDate = [NSDate dateWithTimeIntervalSince1970:shootingDate.longLongValue / 1000.0];
		
	// source
	NSString * source = json[@"source"];
	
	if (!QJ_IS_STR_NIL(source))
		self.source = source;
		
	// open
	NSNumber * open = json[@"open"];
	
	if (!QJ_IS_NUM_NIL(open))
		self.open = open;
		
	// position
	NSString * position = json[@"position"];
	
	if (!QJ_IS_STR_NIL(position))
		self.position = position;
		
	// rank
	NSNumber * rank = json[@"rank"];
	
	if (!QJ_IS_NUM_NIL(rank))
		self.rank = rank;
		
	// size
	NSNumber * size = json[@"size"];
	
	if (!QJ_IS_NUM_NIL(size))
		self.size = size;
}

@end
