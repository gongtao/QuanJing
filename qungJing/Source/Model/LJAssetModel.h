//
//  LJAssetModel.h
//  Weitu
//
//  Created by qj-app on 15/5/19.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LJAssetModel : NSObject
@property(nonatomic,copy)NSString *assetID;
@property(nonatomic,copy)NSString *caption;
@property(nonatomic,assign)NSNumber*commentNum;
@property(nonatomic,assign)NSNumber *createTime;
@property(nonatomic,retain)NSDictionary *imageInfo;
@property(nonatomic,retain)NSArray *latestComments;
@property(nonatomic,retain)NSArray *likedUserIDs;
@property(nonatomic,copy)NSString *oriPic;
@property(nonatomic,copy)NSString *ownerUserID;
@property(nonatomic,assign)NSNull *position;
@property(nonatomic,assign)NSNumber *privateAsset;
@property(nonatomic,retain)NSArray *relatedAssetIDs;
@property(nonatomic,copy)NSString *webURL;




@end
