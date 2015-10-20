//
//  OWTFeedItem.h
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTFeedItemData.h"

@interface OWTFeedItem : NSObject

@property (nonatomic, copy) NSString* itemID;
@property (nonatomic, assign) long long timestamp;
@property (nonatomic, strong) OWTAsset* asset;

- (void)mergeWithData:(OWTFeedItemData*)feedItemData;

- (NSComparisonResult)compare:(OWTFeedItem*)rhs;

@end
