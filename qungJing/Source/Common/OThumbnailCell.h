//
//  OThumbnailCell.h
//  Weitu
//
//  Created by Su on 5/31/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWTImageInfo.h"



@interface OThumbnailCell : UICollectionViewCell

@property (nonatomic, assign) NSInteger generation;
@property (nonatomic, strong) UIImage* image;



- (void)setThumbnailWithImage:(UIImage *)image;
//- (void)setThumbnailWithImageInfo:(OWTImageInfo *)imageInfo;
- (void)setThumbnailWithImageInfo:(NSArray*) thumbImageInfos index:(NSInteger)index;



@property (nonatomic, strong) void ((^showImage)());
@end
