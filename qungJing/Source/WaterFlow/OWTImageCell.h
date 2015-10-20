//
//  OWaterFlowCell.h
//  Weitu
//
//  Created by Su on 3/8/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWTImageView.h"

@interface OWTImageCell : UICollectionViewCell

@property (nonatomic, strong) OWTImageView* imageView;

- (void)setImageWithInfo:(OWTImageInfo*)imageInfo;
- (void)setImageWithImage:(UIImage*)image;
- (void)clearImage;

@end
