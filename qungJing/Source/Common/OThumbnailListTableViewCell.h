//
//  OThumbnailListTableViewCell.h
//  Weitu
//
//  Created by Su on 6/2/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OThumbnailListViewCon.h"
#import "OThumbnailListTableViewItem.h"
#import <RETableViewManager/RETableViewCell.h>

@interface OThumbnailListTableViewCell : RETableViewCell

@property (strong, readwrite, nonatomic) OThumbnailListTableViewItem* item;

@property (nonatomic, strong, readonly) OThumbnailListViewCon* thumbnailListViewCon;

@end
