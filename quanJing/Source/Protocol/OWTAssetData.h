//
//  OWTAsset.h
//  Weitu
//
//  Created by Su on 3/10/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWTImageInfo.h"

@interface OWTAssetData : NSObject

@property (nonatomic, copy) NSString* assetID;
@property (nonatomic, copy) NSString* caption;
@property (nonatomic, copy) NSString* oriPic;
@property (nonatomic, copy) NSString*webURL;
@property (nonatomic, copy) NSString* serial;
@property (nonatomic, copy) NSString* ownerUserID;
@property (nonatomic, copy) NSNumber* isPrivate; 
@property (nonatomic, strong) OWTImageInfo* imageInfo;
@property (nonatomic, copy) NSNumber* likedUserNum;
@property (nonatomic, copy) NSNumber* commentNum;
@property (nonatomic, copy) NSArray* latestCommentDatas;
@property (nonatomic, copy) NSArray* commentDatas;
@property (nonatomic, copy) NSArray* likedUserIDs;
@property(nonatomic,strong)NSNumber *createTime;
@property(nonatomic,copy)NSString *keywords;
@property(nonatomic,copy)NSString *position;

@end
