//
//  OWTFeedItem.h
//  Weitu
//
//  Created by Su on 3/31/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWTFeedItemData : NSObject

@property (nonatomic, copy) NSString* itemID;
@property (nonatomic, copy) NSNumber* timestamp;
@property (nonatomic, strong) OWTAssetData* assetData;

@end
