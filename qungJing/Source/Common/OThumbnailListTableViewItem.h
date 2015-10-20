//
//  OThumbnailListTableViewItem.h
//  Weitu
//
//  Created by Su on 6/2/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "RETableViewItem.h"

extern NSString* kThumbnailListImagesUpdatedNotification;

@interface OThumbnailListTableViewItem : RETableViewItem

@property (nonatomic, copy) NSArray* images;
@property (nonatomic, copy) NSArray* imageInfos;

@end
