//
//  OWTAsset.h
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTAssetData.h"
#import "QuanJingSDK.h"
@interface OWTAsset : NSObject

@property (nonatomic, strong) NSString* assetID;
@property (nonatomic, strong) NSString* caption;
@property (nonatomic, strong) NSString* serial;
@property (nonatomic, strong) NSString* ownerUserID;
@property (nonatomic,strong)  NSNumber*createTime;
@property (nonatomic, strong) NSString* oriPic;
@property (nonatomic, strong) NSString* webURL;
//
@property (nonatomic, strong) NSString* location;
@property (nonatomic, strong) NSString* keywords;

@property (nonatomic, strong) OWTImageInfo* imageInfo;
@property (nonatomic, assign) NSInteger likeNum;
@property (nonatomic, assign) NSInteger commentNum;
@property (nonatomic, strong) NSMutableArray* latestComments;
@property (nonatomic, strong) NSMutableArray* comments;
@property (nonatomic, strong) NSMutableSet* likedUserIDs;
@property (nonatomic, strong) NSOrderedSet* relatedAssets;
@property (nonatomic, assign) BOOL isPrivate;

- (void)markLikedByUser:(NSString*)userID;
- (void)markUnlikedByUser:(NSString*)userID;
- (BOOL)isLikedByUser:(NSString*)userID;

- (void)addComment:(OWTComment*)comment;

- (void)mergeWithData:(OWTAssetData*)assetData;
- (void)mergeWithRelatedAssets:(NSArray*)relatedAssets;
- (void)getFromModel:(QJImageObject*)model;
@end
